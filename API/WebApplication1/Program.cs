using WepApi.Services;
using WepApi.Context;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddCors(options =>
{
    // T�m isteklere izin veren CORS politikas�
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
// Swagger/OpenAPI yap�land�rmas�
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddDbContext<ApplicationDbContext>();
builder.Services.AddScoped<LoginServices>();
builder.Services.AddScoped<TeacherServices>();

var app = builder.Build();

// CORS politikas�n� aktif hale getir
app.UseCors("AllowAllOrigins");  // Bu sat�r CORS politikas�n� uyguluyor

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
