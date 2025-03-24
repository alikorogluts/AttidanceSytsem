namespace WepApi.Dto.TeacherDtos
{
    public class GetAttendancesByTeacher
    {
        public class LessonAttendancesViewModel
        {
            public int LessonId { get; set; }
            public string LessonName { get; set; }
            public List<SessionAttendancesViewModel> Sessions { get; set; }
        }

        public class SessionAttendancesViewModel
        {
            public DateTime SessionDate { get; set; }
            public TimeSpan StartTime { get; set; }
            public TimeSpan EndTime { get; set; }
            public List<AttendanceViewModel> Attendances { get; set; }
        }

        public class AttendanceViewModel
        {
            public int AttendanceId { get; set; }
            public StudentViewModel Student { get; set; }
            public string Status { get; set; }
            public TimeSpan StartTime { get; set; }
            public TimeSpan EndTime { get; set; }
            public string? Explanation { get; set; } // İzin sebebi eklendi

        }

        public class StudentViewModel
        {
            public int StudentId { get; set; }
            public string FullName { get; set; }
        }

    }
}
