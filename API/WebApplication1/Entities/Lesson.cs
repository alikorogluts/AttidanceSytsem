using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace WepApi.Entities
{
    public class Lesson
    {
        [Key]
        public int LessonId { get; set; }

        [Required]
        [StringLength(100)]
        public string Name { get; set; } = "Yeni Ders";

        [Range(1, 16)]
        public int TotalWeeks { get; set; } = 14;

        [Range(1, 7)]
        public int SessionsPerWeek { get; set; } = 2;

        [Range(1, 50)]
        public int MaxAbsence { get; set; } = 5;

        [Required]
        [StringLength(10)]
        public string UniqueCode { get; set; } = Guid.NewGuid().ToString()[..8];

        // İlişkiler
        [ForeignKey("Teacher")]
        
        public int TeacherId { get; set; }
        public Teacher Teacher { get; set; }
        
        public List<StudentLesson> StudentLessons { get; set; } = new();

        [NotMapped]
        public int CompletedWeeks =>
            (StudentLessons.Sum(sl => sl.Attendances.Count(a => a.Status == AttendanceStatus.Present)) / SessionsPerWeek);
        [NotMapped]
        public int TotalPeriods => SessionsPerWeek * TotalWeeks;
    }
}