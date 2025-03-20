using Microsoft.EntityFrameworkCore;
using WepApi.Context;
using WepApi.Entities;

namespace WepApi.Services
{
    public class TeacherServices
    {
        public readonly ApplicationDbContext _context;

        public TeacherServices(ApplicationDbContext context)
        {
            _context = context;
        }

        public string GenerateUnicCode()
        {
            string code;
            do
            {
                const string chars = "ACDEFGHJKLMNPRTUVWXYZ234679"; // Karıştırılmış karakter seti
                var random = new Random();
                code = new string(Enumerable.Repeat(chars, 6).Select(s => s[random.Next(s.Length)]).ToArray());

            }
            while (_context.Lessons.Any(l => l.UniqueCode == code));
            return code;
        }
        public Teacher GetTeacher(string Email)
        {
            var email = Email;
            return _context.Teachers
                  .Include(t => t.Lessons)
                  .FirstOrDefault(t => t.Email == email);
        }
    }
}
