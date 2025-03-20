using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace WepApi.Entities
{
    public class StudentLesson
    {
        [Key]
        public int Id { get; set; }

        [Range(0, 50, ErrorMessage = "Devamsızlık 0-50 aralığında olmalıdır.")]
        public int AbsenceCount { get; set; }

        // İlişkiler
        [ForeignKey("Student")]
        public int StudentId { get; set; }
        public Student Student { get; set; }

        [ForeignKey("Lesson")]
        public int LessonId { get; set; }

        public Lesson Lesson { get; set; }

        // Navigation Property
        public ICollection<Attendance> Attendances { get; set; } = new List<Attendance>();
    }
}