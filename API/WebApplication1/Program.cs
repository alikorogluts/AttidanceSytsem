using WepApi.Services;
using WepApi.Context;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddCors(options =>
{
    // Tüm isteklere izin veren CORS politikası
    options.AddPolicy("AllowAllOrigins", builder =>
    {
        builder.AllowAnyOrigin()  // Herhangi bir origin'e izin verir.
               .AllowAnyMethod()  // Herhangi bir HTTP metoduna izin verir.
               .AllowAnyHeader(); // Herhangi bir header'a izin verir.
    });
});
builder.Services.AddControllers()
    .AddNewtonsoftJson(options =>
    {
        options.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore;
    });


builder.Services.AddControllers();
// Swagger/OpenAPI yapılandırması
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddDbContext<ApplicationDbContext>();
builder.Services.AddScoped<LoginServices>();
builder.Services.AddScoped<TeacherServices>();

var app = builder.Build();

// CORS politikasını aktif hale getir
app.UseCors("AllowAllOrigins");  // Bu satır CORS politikasını uyguluyor

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
