using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Org.BouncyCastle.Asn1.Ocsp;
using System.Runtime.InteropServices;
using WepApi.Context;
using WepApi.Dto.TeacherDtos;
using WepApi.Entities;
using WepApi.Services;
using static WepApi.Dto.TeacherDtos.GetAttendancesByTeacher;

namespace WepApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TeacherController : ControllerBase
    {
        private readonly TeacherServices _teacherServices;
        private readonly ApplicationDbContext _context;

        public TeacherController(ApplicationDbContext context, TeacherServices teacherServices)
        {
            _context = context;
            _teacherServices = teacherServices;
        }

        [HttpPost("CreateLesson")]
        public IActionResult CreateLesson([FromBody] CreateLessonRequestDto data)
        {
            var teacher = _teacherServices.GetTeacher(data.email.ToString());
            if (teacher == null)
            {
                return BadRequest(new { mesage = "Öğretim görevlisi bulunamadı." });
            }
            Lesson model = new Lesson();
            model.UniqueCode= _teacherServices.GenerateUnicCode();
            model.TeacherId = teacher.TeacherId;
            model.Name = data.lessonName;
            model.TotalWeeks = data.totalWeeks;
            model.SessionsPerWeek = data.sessionsPerWeek;
            model.MaxAbsence = data.maxAbsence;


            model.StudentLessons = new List<StudentLesson>();
            try
            {
                _context.Lessons.Add(model);
                _context.SaveChanges();

                return Ok(new {mesage ="Ders Başarı ile Oluşturuldu" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { mesage = $"Ders oluşturulmadı hata kodu ={ex.Message} " });
            }

        }
        [HttpGet("GetLesson")]
        public IActionResult GetLesson([FromQuery] GetLessonRequestDto data)
        {
            if (string.IsNullOrWhiteSpace(data.email))
            {
                return BadRequest(new { message = "Geçerli bir e-posta adresi giriniz." });
            }

            // Öğretim görevlisini email ile al
            var teacher = _teacherServices.GetTeacher(data.email);
            if (teacher == null)
            {
                return NotFound(new { message = "Öğretim görevlisi bulunamadı." });
            }

            // Bu öğretmenin derslerini al
            var lessons = _context.Lessons
                .Where(l => l.TeacherId == teacher.TeacherId) // TeacherId ile filtrele
                .Select(l => new
                {
                    l.LessonId,
                    l.Name,
                    l.TotalWeeks,
                    l.SessionsPerWeek,
                    l.MaxAbsence,
                    l.UniqueCode,
                    StudentCount = l.StudentLessons.Count() // Öğrenci sayısını hesapla

                })
                .ToList(); // Sadece ders bilgilerini al

            if (!lessons.Any())
            {
                return NotFound(new { message = "Bu öğretim görevlisinin dersi bulunmamaktadır." });
            }

            return Ok(lessons); // Dersler listesi
        }


        [HttpGet("GetLessonStudentList")]
        public IActionResult GetLessonStudentList([FromQuery] GetLessonStudentListRequestDto data)
        {
            var studentList = _context.StudentLessons
                .Where(StudentLesson => StudentLesson.LessonId == data.LessonId)
                .Select(l => new
                {
                    l.Id,
                    l.StudentId,
                    l.Student.FullName,
                    l.AbsenceCount
                })
                .ToList();
            


            if (studentList == null) return BadRequest("Ders bulunamadı");

            return Ok(studentList);
        }

        [HttpDelete("DeleteLessonStudent")]
        public IActionResult DeleteLessonStudent(int studentLessonId)
        {
            try
            {
                

                var studentLesson = _context.StudentLessons
                    .Include(sl => sl.Lesson)
                    .Include(sl => sl.Attendances) // Öğrencinin yoklamalarını da dahil ettik
                    .FirstOrDefault(sl => sl.Id == studentLessonId );

                if (studentLesson == null)
                    return BadRequest(new { success = false, message = "Öğrenci bulunamadı." });

                // Önce öğrencinin yoklamalarını siliyoruz
                _context.Attendances.RemoveRange(studentLesson.Attendances);

                // Sonrasında öğrenci-derse kaydını siliyoruz
                _context.StudentLessons.Remove(studentLesson);
                _context.SaveChanges();

                // Güncellenmiş öğrenci sayısını hesaplıyoruz

                return Ok(new { success = true,message="Silme işlemi başarılı"});
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }


        [HttpPost("SaveAttendance")]
        public IActionResult SaveAttendance([FromBody] SaveAttendanceDto model)
        {
            if (model == null)
                return BadRequest(new { success = false, message = "Geçersiz veri formatı!" });

            if (model.LessonId <= 0)
                return BadRequest(new { success = false, message = "Geçersiz ders ID!" });

            if (model.Attendances == null || !model.Attendances.Any())
                return BadRequest(new { success = false, message = "Yoklama verisi bulunamadı!" });

            if (!TimeSpan.TryParse(model.StartTime, out TimeSpan startTime))
                return BadRequest(new { success = false, message = "Geçersiz başlangıç saati formatı!" });

            var lesson = _context.Lessons
                .Include(l => l.StudentLessons)
                .FirstOrDefault(l => l.LessonId == model.LessonId);

            if (lesson?.StudentLessons == null || !lesson.StudentLessons.Any())
                return NotFound(new { success = false, message = "Ders veya öğrenci kayıtları bulunamadı!" });

            foreach (var item in model.Attendances)
            {
                if (item.Status == AttendanceStatus.Excused && string.IsNullOrWhiteSpace(item.Explanation))
                {
                    return BadRequest(new
                    {
                        success = false,
                        message = $"{item.StudentLessonId} ID'li öğrenci için açıklama zorunludur!"
                    });
                }

                var studentLesson = lesson.StudentLessons
                    .FirstOrDefault(sl => sl.Id == item.StudentLessonId);

                if (studentLesson == null)
                {
                    return NotFound(new
                    {
                        success = false,
                        message = $"{item.StudentLessonId} ID'li öğrenci-ders kaydı bulunamadı!"
                    });
                }

                var rawEndTime = startTime.Add(TimeSpan.FromMinutes(45 * model.LessonPeriod));
                var normalizedEndTime = TimeSpan.FromSeconds(rawEndTime.TotalSeconds % (24 * 60 * 60));

                var attendance = new Attendance
                {
                    StudentId = item.StudentId,
                    StudentLessonId = item.StudentLessonId,
                    SessionDate = DateTime.Now,
                    LessonPeriod = model.LessonPeriod,
                    StartTime = startTime,
                    EndTime = normalizedEndTime,
                    Status = item.Status,
                    Explanation = item.Status == AttendanceStatus.Excused ? item.Explanation : null
                };

                if (item.Status == AttendanceStatus.Absent)
                {
                    studentLesson.AbsenceCount += model.LessonPeriod;
                    studentLesson.AbsenceCount = Math.Max(studentLesson.AbsenceCount, 0);
                }

                _context.Attendances.Add(attendance);
            }

            try
            {
                _context.SaveChanges();
            }
            catch (DbUpdateException dbEx)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Veritabanı hatası: " + dbEx.InnerException?.Message
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Beklenmeyen hata: " + ex.Message
                });
            }

            return Ok(new
            {
                success = true,
                message = "Yoklama başarıyla kaydedildi!",
                affectedStudents = model.Attendances.Count
            });
        }




        [HttpGet("GetAttendancesByTeacher/{teacherEmail}")]
        public IActionResult GetAttendancesByTeacher(string teacherEmail)
        {
            var teacher = _context.Teachers.FirstOrDefault(t => t.Email == teacherEmail);
            var teacherId = teacher.TeacherId;
            var lessons = _context.Lessons
                .Where(l => l.TeacherId == teacherId)
                .Include(l => l.StudentLessons)
                    .ThenInclude(sl => sl.Attendances)
                        .ThenInclude(a => a.Student)
                .Select(l => new LessonAttendancesViewModel
                {
                    LessonId = l.LessonId,
                    LessonName = l.Name,
                    Sessions = l.StudentLessons
                        .SelectMany(sl => sl.Attendances)
                        .GroupBy(a => new { a.SessionDate, a.StartTime, a.EndTime })
                        .OrderByDescending(g => g.Key.SessionDate)
                        .ThenBy(g => g.Key.StartTime)
                        .Select(g => new SessionAttendancesViewModel
                        {
                            SessionDate = g.Key.SessionDate,
                            StartTime = g.Key.StartTime,
                            EndTime = g.Key.EndTime,
                            Attendances = g.Select(a => new AttendanceViewModel
                            {
                                AttendanceId = a.AttendanceId,
                                Student = new StudentViewModel
                                {
                                    StudentId = a.Student.StudentId,
                                    FullName = a.Student.FullName
                                },
                                Status = a.Status.ToString(),
                                StartTime = a.StartTime,
                                EndTime = a.EndTime,
                                Explanation = a.Status == AttendanceStatus.Excused ? a.Explanation : null // İzinli olanlar için sebep ekleniyor
                            }).ToList()
                        })
                        .ToList()
                })
                .ToList();

            if (!lessons.Any())
            {
                return NotFound("Öğretmene ait yoklama kaydı bulunamadı.");
            }

            return Ok(lessons);
        }


        [HttpPut("UpdateAttendance")]
        public IActionResult UpdateAttendance([FromBody] UpdateAttendanceDto model)
        {
            var attendance = _context.Attendances
                .Include(a => a.StudentLesson)
                .FirstOrDefault(a => a.AttendanceId == model.AttendanceId);

            if (attendance == null)
            {
                return BadRequest(new { success = false, message = "Kayıtlı yoklama bulunamadı" });
            }

            if (model.Status.ToString() == "Excused" && string.IsNullOrWhiteSpace(model.Explanation))
            {
                return BadRequest(new { success = false, message = "Açıklama zorunlu!" });
            }

            if (!Enum.TryParse<AttendanceStatus>(model.Status.ToString(), out var newStatus))
            {
                return BadRequest(new { success = false, message = "Geçersiz durum!" });
            }

            // Eğer gelen durum, database'deki mevcut durumla aynı ise hiçbir işlem yapmadan döndür.
            if (attendance.Status == newStatus)
            {
                return Ok(new { success = true, message = "Güncelleme yapılmadı, çünkü durum değişmedi." });
            }

            var duration = (int)(attendance.EndTime - attendance.StartTime).TotalHours + 1;

            if (attendance.Status == AttendanceStatus.Absent && newStatus != AttendanceStatus.Absent)
            {
                attendance.StudentLesson.AbsenceCount -= duration;
            }
            else if (attendance.Status != AttendanceStatus.Absent && newStatus == AttendanceStatus.Absent)
            {
                attendance.StudentLesson.AbsenceCount += duration;
            }

            attendance.Status = newStatus;
            attendance.Explanation = newStatus == AttendanceStatus.Excused ? model.Explanation : null;

            _context.SaveChanges();

            return Ok(new { success = true, message = "İşlem Başarılı" });
        }


    }








}

