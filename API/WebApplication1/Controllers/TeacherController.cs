using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Runtime.InteropServices;
using WepApi.Context;
using WepApi.Dto.TeacherDtos;
using WepApi.Entities;
using WepApi.Services;

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

            var teacher = _teacherServices.GetTeacher(data.email);
            if (teacher == null)
            {
                return NotFound(new { message = "Öğretim görevlisi bulunamadı." });
            }

            var lessons = _context.Lessons
                .Include(l => l.StudentLessons)
                .Where(l => l.TeacherId == teacher.TeacherId)
                .ToList();
            

            if (!lessons.Any())
            {
                return NotFound(new { message = "Bu öğretim görevlisinin dersi bulunmamaktadır." });
            }

            return Ok(lessons);
        }

        [HttpGet("GetLessonStudentList")]
        public IActionResult GetLessonList([FromQuery] GetLessonStudentListRequestDto data)
        {
            var studentList = _context.StudentLessons
                .Where(StudentLesson => StudentLesson.LessonId == data.LessonId)
                .ToList();
            


            if (studentList == null) return BadRequest("Ders bulunamadı");

            return Ok(studentList);
        }






    }
}
