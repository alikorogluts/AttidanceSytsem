namespace WepApi.Dto.TeacherDtos
{
    public class UpdateAttendanceDto
    {
        public int AttendanceId { get; set; }

        public UpdateAttendanceStatus Status { get; set; }
        public string? Explanation { get; set; }

    }
    public enum UpdateAttendanceStatus
    {
        Present,    // Katıldı
        Absent,     // Katılmadı
        Excused     // İzinli
    }
}
