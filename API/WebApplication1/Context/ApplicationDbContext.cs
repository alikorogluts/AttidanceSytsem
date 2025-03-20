using Microsoft.EntityFrameworkCore;
using WepApi.Entities;


namespace WepApi.Context
{
    public class ApplicationDbContext : DbContext
    {
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.UseSqlServer("Server=DESKTOP-83AGMDV\\MSSQLSERVER61;initial catalog=ApiMobileDb;integrated security=true;");
        }
        public DbSet<Teacher> Teachers { get; set; }
        public DbSet<Student> Students { get; set; }
        public DbSet<Lesson> Lessons { get; set; }
        public DbSet<StudentLesson> StudentLessons { get; set; }
        public DbSet<Attendance> Attendances { get; set; }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // StudentLesson - Attendance İlişkisi
            modelBuilder.Entity<Attendance>()
                .HasOne(a => a.StudentLesson)
                .WithMany(sl => sl.Attendances)
                .HasForeignKey(a => a.StudentLessonId)
                .OnDelete(DeleteBehavior.Restrict);

            // Student - StudentLesson İlişkisi
            modelBuilder.Entity<StudentLesson>()
                .HasOne(sl => sl.Student)
                .WithMany(s => s.StudentLessons)
                .HasForeignKey(sl => sl.StudentId)
                .OnDelete(DeleteBehavior.Restrict);

            // Lesson - StudentLesson İlişkisi
            modelBuilder.Entity<StudentLesson>()
                .HasOne(sl => sl.Lesson)
                .WithMany(l => l.StudentLessons)
                .HasForeignKey(sl => sl.LessonId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
