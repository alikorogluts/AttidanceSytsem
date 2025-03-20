using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace WepApi.Entities
{
    public class Teacher
    {
        [Key]
        public int TeacherId { get; set; }

        [Required]
        [StringLength(100)]
        public string FullName { get; set; } = "Öğretmen Adı";

        [Required]
        [EmailAddress]
        public string Email { get; set; } = "ogretmen@mail.com";

        [Required]
        [DataType(DataType.Password)]
        public string Password { get; set; } = "Sifre123!";

        // Navigation Property
        public ICollection<Lesson> Lessons { get; set; } = new List<Lesson>();
    }
}