using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WepApi.Entities
{
    public class Student
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int StudentId { get; set; }  // Bu değeri siz atayacaksınız


        [Required]
        [StringLength(100)]
        public string FullName { get; set; } = "Öğrenci Adı";

        [Required]
        [EmailAddress]
        public string Email { get; set; } = "ornek@mail.com";

        [Required]
        [DataType(DataType.Password)]
        public string Password { get; set; } = "Sifre123!";

        //[NotMapped]
        //[DataType(DataType.Password)]
        //[Compare("Password", ErrorMessage = "Şifreler uyuşmuyor!")]
        //public string RePassword { get; set; }

        // Navigation Properties
        public ICollection<StudentLesson> StudentLessons { get; set; } = new List<StudentLesson>();
    }
}