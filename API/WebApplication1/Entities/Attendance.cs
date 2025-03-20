using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WepApi.Entities
{
    public class Attendance
    {
        [Key]
        public int AttendanceId { get; set; }

        [Required]
        [ForeignKey("Student")]
        public int StudentId { get; set; }

        [Required]
        [ForeignKey("StudentLesson")]
        public int StudentLessonId { get; set; }





        [Required]
        public DateTime SessionDate { get; set; }

        [Required]
        [Range(1, 4)]
        public int LessonPeriod { get; set; }

        [Required]
        public TimeSpan StartTime { get; set; }

        [Required]
        public TimeSpan EndTime { get; set; }

        [Required]
        public AttendanceStatus Status { get; set; }

        [StringLength(500)]
        public string? Explanation { get; set; }

        public DateTime? ModifiedDate { get; set; }
        public bool IsDeleted { get; set; }

        // Navigation Properties
        public Student Student { get; set; }
        public StudentLesson StudentLesson { get; set; }
    }

    public enum AttendanceStatus
    {
        Present,    // Katıldı
        Absent,     // Katılmadı
        Excused     // İzinli
    }
}