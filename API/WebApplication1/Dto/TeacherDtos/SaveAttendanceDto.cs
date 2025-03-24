using System.ComponentModel.DataAnnotations;
using WepApi.Entities;

namespace WepApi.Dto.TeacherDtos
{
    public class SaveAttendanceDto
    {
        
            [Required]
            [Range(1, int.MaxValue)]
            public int LessonId { get; set; }

            [Required]
            [Range(1, 4)]
            public int LessonPeriod { get; set; }

            [Required]
            [RegularExpression(@"^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$")]
            public string StartTime { get; set; }

            [Required]
            [MinLength(1)]
            public List<AttendanceItem> Attendances { get; set; }
        

        public class AttendanceItem
        {
            [Required]
            [Range(1, int.MaxValue)]
            public int StudentLessonId { get; set; }
            public int StudentId { get; set; } // Yeni eklenen alan


            [Required]
            public AttendanceStatus Status { get; set; }

            [StringLength(500)]
            public string Explanation { get; set; }
        }

    }
}
