using Microsoft.AspNetCore.Mvc;
using Supabase;
using LifeStyleCarwash.Web.Models;
using System.Text.Json;

namespace LifeStyleCarwash.Web.Controllers
{
    public class HomeController : Controller
    {
        private readonly Client _supabase;

        public HomeController(Client supabase)
        {
            _supabase = supabase;
        }

        [HttpGet]
        public IActionResult Index()
        {
            if (HttpContext.Session.GetString("StaffUser") != null) return RedirectToAction("Dashboard");
            return View();
        }

        [HttpPost]
        public IActionResult Index(LoginViewModel model)
        {
            if (ModelState.IsValid)
            {
                if (model.Username == "admin" && model.Password == "carwash123")
                {
                    HttpContext.Session.SetString("StaffUser", model.Username);
                    return RedirectToAction("Dashboard");
                }
                ViewBag.Error = "Invalid username or password.";
            }
            return View(model);
        }

        [ResponseCache(Location = ResponseCacheLocation.None, NoStore = true)]
        public async Task<IActionResult> Dashboard()
        {
            if (HttpContext.Session.GetString("StaffUser") == null) return RedirectToAction("Index");

            var response = await _supabase.From<Bookings>().Get();
            var bookings = response.Models;

            var staffResponse = await _supabase.From<Staff>().Get();
            var staffList = staffResponse.Models;

            ViewBag.TotalBookings = bookings.Count;
            ViewBag.Waiting = bookings.Count(b => b.Status == "Waiting");
            ViewBag.InProgress = bookings.Count(b => b.Status == "In Progress");
            ViewBag.Ready = bookings.Count(b => b.Status == "Ready");

            // FIX: Available staff checks the Staff table status
            ViewBag.AvailableStaff = staffList.Count(s => s.Status == "Available");

            int baysInUse = bookings.Where(b => b.Status != "Ready" && !string.IsNullOrEmpty(b.AssignedBay)).Select(b => b.AssignedBay).Distinct().Count();
            ViewBag.AvailableBays = 6 - baysInUse;

            var activeBookings = bookings.Where(b => b.Status != "Ready").ToList();
            return View(activeBookings);
        }

        public async Task<IActionResult> ManageBooking()
        {
            if (HttpContext.Session.GetString("StaffUser") == null) return RedirectToAction("Index");

            var response = await _supabase.From<Bookings>().Order(b => b.Id, Supabase.Postgrest.Constants.Ordering.Ascending).Get();
            var staffResponse = await _supabase.From<Staff>().Get();

            ViewBag.StaffList = staffResponse?.Models ?? new List<Staff>();

            var bookings = response.Models;

            ViewBag.OccupiedBays = bookings.Where(b => !string.IsNullOrEmpty(b.AssignedBay) && b.Status != "Ready").Select(b => b.AssignedBay).ToList();
            ViewBag.OccupiedStaff = bookings.Where(b => !string.IsNullOrEmpty(b.AssignedStaff) && b.Status != "Ready").Select(b => b.AssignedStaff).ToList();

            var activeBookings = bookings.Where(b => b.Status != "Ready").ToList();
            return View(activeBookings);
        }

        [HttpPost]
        public async Task<IActionResult> UpdateBooking(long id, string status, string bay, string staffName)
        {
            try
            {
                var response = await _supabase.From<Bookings>().Where(b => b.Id == id).Get();
                var booking = response.Models.FirstOrDefault();

                if (booking != null)
                {
                    if (!string.IsNullOrEmpty(staffName) && staffName != booking.AssignedStaff)
                    {
                        var staffResponse = await _supabase.From<Staff>().Where(s => s.Name == staffName).Get();
                        var staffMember = staffResponse.Models.FirstOrDefault();
                        if (staffMember != null)
                        {
                            staffMember.Status = "Busy";
                            await _supabase.From<Staff>().Where(s => s.Id == staffMember.Id).Update(staffMember);
                        }
                    }

                    if (string.IsNullOrEmpty(staffName) && !string.IsNullOrEmpty(booking.AssignedStaff))
                    {
                        var oldStaffResponse = await _supabase.From<Staff>().Where(s => s.Name == booking.AssignedStaff).Get();
                        var oldStaffMember = oldStaffResponse.Models.FirstOrDefault();
                        if (oldStaffMember != null)
                        {
                            oldStaffMember.Status = "Available";
                            await _supabase.From<Staff>().Where(s => s.Id == oldStaffMember.Id).Update(oldStaffMember);
                        }
                    }

                    booking.Status = status;
                    booking.AssignedBay = bay;
                    booking.AssignedStaff = staffName;

                    await _supabase.From<Bookings>().Where(b => b.Id == id).Update(booking);
                    TempData["SuccessMessage"] = $"Booking #{id} updated successfully!";
                }
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "UPDATE FAILED: " + ex.Message;
            }

            return RedirectToAction("Dashboard");
        }

        // FIXED: Added Staff Status update logic here
        [HttpPost]
        public async Task<IActionResult> UpdateQueueRow(long id, string status, string bay, string staffName)
        {
            try
            {
                var response = await _supabase.From<Bookings>().Where(b => b.Id == id).Get();
                var booking = response.Models.FirstOrDefault();

                if (booking != null)
                {
                    // Mark newly assigned staff as Busy
                    if (!string.IsNullOrEmpty(staffName) && staffName != booking.AssignedStaff)
                    {
                        var staffResponse = await _supabase.From<Staff>().Where(s => s.Name == staffName).Get();
                        var staffMember = staffResponse.Models.FirstOrDefault();
                        if (staffMember != null)
                        {
                            staffMember.Status = "Busy";
                            await _supabase.From<Staff>().Where(s => s.Id == staffMember.Id).Update(staffMember);
                        }
                    }

                    // Free old staff if unassigned
                    if (string.IsNullOrEmpty(staffName) && !string.IsNullOrEmpty(booking.AssignedStaff))
                    {
                        var oldStaffResponse = await _supabase.From<Staff>().Where(s => s.Name == booking.AssignedStaff).Get();
                        var oldStaffMember = oldStaffResponse.Models.FirstOrDefault();
                        if (oldStaffMember != null)
                        {
                            oldStaffMember.Status = "Available";
                            await _supabase.From<Staff>().Where(s => s.Id == oldStaffMember.Id).Update(oldStaffMember);
                        }
                    }

                    booking.Status = (status == "Ready") ? "In Progress" : status;
                    booking.AssignedBay = bay;
                    booking.AssignedStaff = staffName;

                    await _supabase.From<Bookings>().Where(b => b.Id == id).Update(booking);
                    TempData["SuccessMessage"] = $"Ticket #{id} updated successfully!";
                }
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "UPDATE FAILED: " + ex.Message;
            }

            return RedirectToAction("ManageBooking");
        }

        public async Task<IActionResult> StaffUpdate()
        {
            if (HttpContext.Session.GetString("StaffUser") == null) return RedirectToAction("Index");

            var response = await _supabase.From<Bookings>().Get();
            var activeCars = response.Models.Where(b => b.Status == "In Progress").ToList();

            return View(activeCars);
        }

        [HttpPost]
        public async Task<IActionResult> UpdateCarStatus(long id, string newStatus)
        {
            try
            {
                var response = await _supabase.From<Bookings>().Where(b => b.Id == id).Get();
                var booking = response.Models.FirstOrDefault();

                if (booking != null)
                {
                    if (newStatus == "Ready" && !string.IsNullOrEmpty(booking.AssignedStaff))
                    {
                        var staffResponse = await _supabase.From<Staff>().Where(s => s.Name == booking.AssignedStaff).Get();
                        var staffMember = staffResponse.Models.FirstOrDefault();

                        if (staffMember != null)
                        {
                            staffMember.Status = "Available";
                            await _supabase.From<Staff>().Where(s => s.Id == staffMember.Id).Update(staffMember);
                        }
                    }

                    booking.Status = newStatus;

                    if (newStatus == "Ready" || newStatus == "Waiting")
                    {
                        booking.AssignedBay = "";
                        booking.AssignedStaff = "";
                    }

                    await _supabase.From<Bookings>().Where(b => b.Id == id).Update(booking);
                    TempData["SuccessMessage"] = $"Ticket #{id} is now {newStatus}!";
                }
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "UPDATE FAILED: " + ex.Message;
            }

            return RedirectToAction("StaffUpdate");
        }

        public async Task<IActionResult> CustomerInfo(long id)
        {
            if (HttpContext.Session.GetString("StaffUser") == null) return RedirectToAction("Index");

            var response = await _supabase.From<Bookings>().Where(b => b.Id == id).Get();
            var booking = response.Models.FirstOrDefault();

            if (booking == null || booking.Status == "Ready") return RedirectToAction("Dashboard");

            var staffResponse = await _supabase.From<Staff>().Get();
            ViewBag.StaffList = staffResponse.Models;

            var allBookings = await _supabase.From<Bookings>().Get();
            var activeBookings = allBookings.Models.Where(b => b.Status != "Ready" && b.Id != id).ToList();

            ViewBag.OccupiedBays = activeBookings.Where(b => !string.IsNullOrEmpty(b.AssignedBay)).Select(b => b.AssignedBay).ToList();
            ViewBag.OccupiedStaff = activeBookings.Where(b => !string.IsNullOrEmpty(b.AssignedStaff)).Select(b => b.AssignedStaff).ToList();

            return View(booking);
        }

        // FIXED: Send data as JSON strings
        public async Task<IActionResult> Report()
        {
            if (HttpContext.Session.GetString("StaffUser") == null) return RedirectToAction("Index");

            try
            {
                var response = await _supabase.From<Bookings>().Get();
                var bookings = response.Models;

                ViewBag.TotalBookings = bookings.Count;
                ViewBag.Waiting = bookings.Count(b => b.Status == "Waiting");
                ViewBag.InProgress = bookings.Count(b => b.Status == "In Progress");
                ViewBag.Completed = bookings.Count(b => b.Status == "Ready");

                ViewBag.TotalRevenue = bookings.Where(b => b.Status == "Ready" || b.Status == "In Progress").Sum(b => b.AmountPaid);

                // Prepare data for Charts
                var serviceCounts = bookings.GroupBy(b => b.ServiceType)
                                            .Select(g => new { Service = g.Key, Count = g.Count() })
                                            .ToList();

                // Use System.Text.Json to properly format the arrays
                ViewBag.ChartLabels = JsonSerializer.Serialize(serviceCounts.Select(s => s.Service).ToList());
                ViewBag.ChartData = JsonSerializer.Serialize(serviceCounts.Select(s => s.Count).ToList());

                ViewBag.StatusLabels = JsonSerializer.Serialize(new List<string> { "Waiting", "In Progress", "Ready" });
                ViewBag.StatusData = JsonSerializer.Serialize(new List<int> { ViewBag.Waiting, ViewBag.InProgress, ViewBag.Completed });

                var history = bookings.Where(b => b.Status == "Ready").OrderByDescending(b => b.Id).ToList();
                return View(history);
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "REPORT ERROR: " + ex.Message;
                return View(new List<Bookings>());
            }
        }

        public IActionResult Logout()
        {
            HttpContext.Session.Clear();
            return RedirectToAction("Index");
        }
    }
}