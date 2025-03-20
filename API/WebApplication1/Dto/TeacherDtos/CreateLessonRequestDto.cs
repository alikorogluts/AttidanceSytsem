namespace WepApi.Dto.TeacherDtos
{
    public class CreateLessonRequestDto
    {
        public string email { get; set; }

        public string lessonName { get; set; }
        public int totalWeeks { get; set; }
        public int sessionsPerWeek { get; set; } 
        public int maxAbsence { get; set; }






    }
}
