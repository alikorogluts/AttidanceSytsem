using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WepApi.Context;
using WepApi.Services;
using WepApi.Dto.AccountDtos;

namespace WepApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AcountController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly LoginServices _services;

        public AcountController(ApplicationDbContext context, LoginServices services)
        {
            _context = context;
            _services = services;
        }

        [HttpPost("Login")]
        public IActionResult Login([FromBody] LoginRequestsDto loginRequests)
        {
            if (loginRequests == null || string.IsNullOrEmpty(loginRequests.email) || string.IsNullOrEmpty(loginRequests.password))
            {
                return BadRequest("E-posta ve şifre boş olamaz.");
            }

            int result = _services.LoginCheck(loginRequests.email, loginRequests.password);
            switch (result)
            {
                case 2: // Öğrenci
                     string Sname=_services.GetUserName(loginRequests.email).ToString();
                    return Ok(new { role = "Student", message = "Giriş başarılı", username=$"{Sname}"});

                case 3: // Öğretim Görevlisi
                    string Tname =_services.GetUserName(loginRequests.email).ToString();
                    return Ok(new { role = "Teacher", message = "Giriş başarılı", username=$"{Tname}" });

                default:
                    return Unauthorized(new { message = "Kimlik bilgileri hatalı" });
            }
        }

        [HttpGet("CheckSession")]
        public IActionResult CheckSession(string email)
        {
            if (string.IsNullOrEmpty(email))
            {
                return BadRequest(new { message = "null" });
            }

            // Önce öğrenciyi ara
            var student = _context.Students.FirstOrDefault(x => x.Email == email);
            if (student != null)
            {
                return Ok(new { message = "True" ,role ="Student"});
            }

            // Eğer öğrenci bulunmazsa, öğretmeni ara
            var teacher = _context.Teachers.FirstOrDefault(x=>x.Email==email); ;
            if (teacher != null)
            {
                return Ok(new { message = "True" ,role ="Teacher" });
            }

            // Ne öğrenci ne de öğretmen bulunduğunda
            return BadRequest(new { message = "null" });
        }

        [HttpPost("Register")]
        public IActionResult Register([FromBody] RegisterRequestDto data)
        {
            string result = _services.RegisterUser(data);
            if (result == "Kayıt başarıyla tamamlandı")
            {
                return Ok(new { message = result });
            }
            else
            {
                return BadRequest(new { message = result });
            }
        }

        [HttpPost("SendCode")]
        public IActionResult SendCode([FromBody] SendCodeRequestDto data)  
        {
            if (string.IsNullOrEmpty(data.email))
            {
                return BadRequest("E-posta boş olamaz.");
            }
            // E-posta adresiyle ilgili işlemler yapılacak
            int kod =_services.SendCode(data.email);
            if (kod == 0)
            {
                return BadRequest(new { message = "Kayıtlı hesabınız bulunmaktadır" });
            }
            return Ok(new { message = "Kod gönderildi" ,code = kod});
        }


    }
}
