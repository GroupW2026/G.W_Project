using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace LifeStyleCarwash.Web.Models
{
    [Table("Staff")]
    public class Staff : BaseModel
    {
        [PrimaryKey("id", false)]
        public long Id { get; set; }

        [Column("name")]
        public string Name { get; set; } = string.Empty;

        [Column("status")]
        public string Status { get; set; } = "Available";
    }
}