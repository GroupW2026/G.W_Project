using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace LifeStyleCarwash.Web.Models
{
    [Table("bookings")]
    public class Bookings : BaseModel
    {
        [PrimaryKey("id", false)]
        public long Id { get; set; }

        [Column("customer_name")]
        public string CustomerName { get; set; } = string.Empty;

        [Column("customer_email")] // ADDED
        public string CustomerEmail { get; set; } = string.Empty;

        [Column("customer_phone")] // ADDED
        public string CustomerPhone { get; set; } = string.Empty;

        [Column("service_type")]
        public string ServiceType { get; set; } = string.Empty;

        [Column("status")]
        public string Status { get; set; } = string.Empty;

        [Column("car_registration")]
        public string CarRegistration { get; set; } = string.Empty;

        [Column("car_model")]
        public string CarModel { get; set; } = string.Empty;

        [Column("amount_paid")]
        public double AmountPaid { get; set; }

        [Column("assigned_bay")]
        public string? AssignedBay { get; set; }

        [Column("assigned_staff")]
        public string? AssignedStaff { get; set; }

        [Column("valuables")]
        public string? Valuables { get; set; }
    }
}