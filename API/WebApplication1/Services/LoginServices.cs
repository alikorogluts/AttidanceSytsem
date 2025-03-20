using WepApi.Entities;
using MailKit.Net.Smtp;
using MimeKit;
using Microsoft.AspNetCore.Identity;
using System.Net.Mail;
using WepApi.Context;
using WepApi.Dto.AccountDtos;

namespace WepApi.Services
{
    public class LoginServices
    {
        private readonly ApplicationDbContext _context;

        public LoginServices(
            ApplicationDbContext context
            )
        {
            _context = context;
        }

        public int LoginCheck(string email, string password)
        {
            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
                return 1;

            var student = _context.Students.FirstOrDefault(s => s.Email == email && s.Password == password);
            if (student != null)
                return 2;

            var teacher = _context.Teachers.FirstOrDefault(t => t.Email == email && t.Password == password);
            if (teacher != null)
                return 3;

            return 1;
        }

        public string RegisterUser(RegisterRequestDto data)
        {
            try
            {
                if (!IsEmailAvailable(data.email))
                {
                    return "Bu e-posta zaten kayıtlı";
                }

                if (data.email.EndsWith("@ogrenci.artvin.edu.tr"))
                {
                    // E-posta adresinde "@" öncesi öğrenci numarası olmalıdır.
                    var prefix = data.email.Split('@')[0];
                    if (!int.TryParse(prefix, out int studentNumber))
                    {
                        return "Geçersiz öğrenci numarası formatı";
                    }
                    var student = new Student
                    {
                        StudentId = studentNumber,
                        Email = data.email,
                        Password = data.password,
                        FullName = data.fullName
                    };

                    _context.Students.Add(student);
                }
                else if (data.email.EndsWith("@artvin.edu.tr"))
                {
                    var teacher = new Teacher
                    {
                        Email = data.email,
                        Password = data.password,
                        FullName = data.fullName
                    };
                    _context.Teachers.Add(teacher);
                }
                else
                {
                    return "Geçersiz e-posta formatı";
                }

                _context.SaveChanges();
                return "Kayıt başarıyla tamamlandı";
            }
            catch (Exception ex)
            {
                return $"Hata: {ex.Message}";
            }
        }

        public int SendCode(string email)
        {
            try
            {
                if (!IsEmailAvailable(email))
                {
                    return 0;
                }
                var code = new Random().Next(100000, 999999);
                var message = new MimeMessage();

                message.From.Add(new MailboxAddress("Sistem Yöneticisi", "alikorogluts@gmail.com"));
                message.To.Add(new MailboxAddress("Kullanıcı", email));
                message.Subject = "Doğrulama Kodu";
                message.Body = new TextPart("plain")
                {
                    Text = $"Doğrulama kodunuz: {code}"
                };

                using var client = new MailKit.Net.Smtp.SmtpClient();
                client.Connect("smtp.gmail.com", 587, false);
                client.Authenticate("alikorogluts@gmail.com", "emys grkk efmd pwtr");
                client.Send(message);
                client.Disconnect(true);

                return code;
            }
            catch
            {
                return 0;
            }
        }

        private bool IsEmailAvailable(string email)
        {
            return !_context.Students.Any(s => s.Email == email) && !_context.Teachers.Any(t => t.Email == email);
        }


        public string GetUserName(string email)
        {
            var student = _context.Students.FirstOrDefault(s => s.Email == email);
            if (student != null)
                return student.FullName;
            var teacher = _context.Teachers.FirstOrDefault(t => t.Email == email);
            return teacher?.FullName;
        }
    }
}
