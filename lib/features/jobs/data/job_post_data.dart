// features/jobs/data/job_post_data.dart
// Feature: Job Posts & Service Requests
//
// Mock dataset of job posts for development and demo.

import 'package:local_connect/features/jobs/models/job_post_model.dart';

// ─────────────────────────────────────────────────────────
//  JOB POST + APPLY SYSTEM — Mock Data
// ─────────────────────────────────────────────────────────

/// All posted job requests (user side — "my requests").
final List<JobPost> dummyJobPosts = [
  const JobPost(
    id: 'job-1',
    title: 'Need Plumber for Kitchen Leak',
    category: 'Plumber',
    description:
        'Kitchen pipe leaking badly since morning. Need someone who can fix it today. Water is dripping near the sink and damaging the cabinet.',
    urgency: JobUrgency.urgent,
    preferredDate: 'Today',
    preferredTime: 'ASAP',
    budget: '\u20b9500 - \u20b91,000',
    pincode: '110001',
    area: 'Connaught Place',
    contactPreference: 'Both',
    postedBy: 'Rahul Verma',
    postedByInitial: 'R',
    timePosted: '25 min ago',
    status: JobStatus.active,
    applicationCount: 4,
  ),
  const JobPost(
    id: 'job-2',
    title: 'AC Not Cooling — Urgent Repair',
    category: 'AC Repair',
    description:
        'Split AC in bedroom not cooling at all. Unit is running but only warm air. Need technician who can diagnose and fix.',
    urgency: JobUrgency.today,
    preferredDate: 'Today',
    preferredTime: 'Evening',
    budget: '\u20b9800 - \u20b92,000',
    pincode: '110001',
    area: 'Rajiv Chowk',
    contactPreference: 'Call',
    postedBy: 'Anita Sharma',
    postedByInitial: 'A',
    timePosted: '1 hour ago',
    status: JobStatus.active,
    applicationCount: 6,
  ),
  const JobPost(
    id: 'job-3',
    title: 'Weekly Home Cleaning',
    category: 'Cleaning',
    description:
        'Need professional cleaner for weekly deep cleaning. 2BHK apartment. Looking for reliable person for recurring weekly service.',
    urgency: JobUrgency.thisWeek,
    preferredDate: 'Saturday',
    preferredTime: 'Morning (9-11 AM)',
    budget: '\u20b9600 per visit',
    pincode: '110001',
    area: 'Janpath',
    contactPreference: 'Chat',
    postedBy: 'Priya Gupta',
    postedByInitial: 'P',
    timePosted: '3 hours ago',
    status: JobStatus.inProgress,
    applicationCount: 8,
  ),
  const JobPost(
    id: 'job-4',
    title: 'Class 10 Maths Tutor Needed',
    category: 'Tutor',
    description:
        'Looking for an experienced maths tutor for CBSE class 10. Need help with board exam preparation. 3 days/week preferred.',
    urgency: JobUrgency.thisWeek,
    preferredDate: 'From next Monday',
    preferredTime: 'Evening (5-7 PM)',
    budget: '\u20b9800 / hour',
    pincode: '110005',
    area: 'Karol Bagh',
    contactPreference: 'Both',
    postedBy: 'Suresh Mehta',
    postedByInitial: 'S',
    timePosted: '5 hours ago',
    status: JobStatus.active,
    applicationCount: 3,
  ),
  const JobPost(
    id: 'job-5',
    title: 'Electrical Wiring for New Room',
    category: 'Electrician',
    description:
        'Need full electrical wiring for a newly constructed room. Includes switch board installation, fan points, and light points.',
    urgency: JobUrgency.flexible,
    preferredDate: 'This weekend',
    preferredTime: 'Any time',
    budget: '\u20b93,000 - \u20b95,000',
    pincode: '110002',
    area: 'Paharganj',
    contactPreference: 'Call',
    postedBy: 'Vikram Singh',
    postedByInitial: 'V',
    timePosted: '1 day ago',
    status: JobStatus.active,
    applicationCount: 2,
  ),
  const JobPost(
    id: 'job-6',
    title: 'Salon Service at Home',
    category: 'Salon',
    description:
        'Need professional hair styling and facial at home for a family event. 2 people. Prefer experienced beautician.',
    urgency: JobUrgency.thisWeek,
    preferredDate: 'Friday',
    preferredTime: 'Morning',
    budget: '\u20b92,000 - \u20b93,500',
    pincode: '110001',
    area: 'Mandi House',
    contactPreference: 'Chat',
    postedBy: 'Neha Kapoor',
    postedByInitial: 'N',
    timePosted: '2 days ago',
    status: JobStatus.completed,
    applicationCount: 5,
  ),
  const JobPost(
    id: 'job-7',
    title: 'Bike Service & Oil Change',
    category: 'Bike Repair',
    description:
        'Honda Activa needs general service and oil change. Also chain cleaning if possible. Prefer doorstep service.',
    urgency: JobUrgency.flexible,
    preferredDate: 'Anytime this week',
    preferredTime: 'Morning',
    budget: '\u20b9400 - \u20b9700',
    pincode: '110005',
    area: 'Karol Bagh',
    contactPreference: 'Both',
    postedBy: 'Amit Jain',
    postedByInitial: 'A',
    timePosted: '3 days ago',
    status: JobStatus.closed,
    applicationCount: 4,
  ),
];

/// Applications from providers for job posts.
final List<JobApplication> dummyApplications = [
  // Applications for job-1 (Plumber - Kitchen Leak)
  const JobApplication(
    id: 'app-1',
    jobId: 'job-1',
    providerName: 'Rajesh Kumar',
    providerService: 'Plumber',
    providerInitial: 'R',
    providerRating: 4.5,
    providerReviewCount: 48,
    providerDistance: '1.2 km',
    providerExperience: '8 years',
    providerVerified: true,
    priceOffer: '\u20b9650',
    message:
        'I can fix your kitchen leak today. I have experience with all pipe types and carry tools for immediate repair.',
    eta: '20 min',
    canStartNow: true,
    appliedTime: '15 min ago',
  ),
  const JobApplication(
    id: 'app-2',
    jobId: 'job-1',
    providerName: 'Sunil Yadav',
    providerService: 'Plumber',
    providerInitial: 'S',
    providerRating: 4.8,
    providerReviewCount: 62,
    providerDistance: '2.5 km',
    providerExperience: '12 years',
    providerVerified: true,
    priceOffer: '\u20b9800',
    message:
        'Expert in kitchen plumbing. Will diagnose the root cause and provide permanent fix. All parts included.',
    eta: '35 min',
    canStartNow: false,
    appliedTime: '20 min ago',
  ),
  const JobApplication(
    id: 'app-3',
    jobId: 'job-1',
    providerName: 'Manoj Plumbing',
    providerService: 'Plumber',
    providerInitial: 'M',
    providerRating: 4.2,
    providerReviewCount: 28,
    providerDistance: '3.8 km',
    providerExperience: '5 years',
    providerVerified: false,
    priceOffer: '\u20b9450',
    message:
        'Available right now. Can come within 30 minutes. Reasonable pricing.',
    eta: '30 min',
    canStartNow: true,
    appliedTime: '22 min ago',
  ),
  const JobApplication(
    id: 'app-4',
    jobId: 'job-1',
    providerName: 'Delhi Home Services',
    providerService: 'Plumber',
    providerInitial: 'D',
    providerRating: 4.6,
    providerReviewCount: 105,
    providerDistance: '1.8 km',
    providerExperience: '10 years',
    providerVerified: true,
    priceOffer: '\u20b9750',
    message:
        'Company-backed plumber with warranty on work. Free inspection. Can provide GST bill.',
    eta: '25 min',
    canStartNow: false,
    appliedTime: '24 min ago',
    status: ApplicationStatus.accepted,
  ),

  // Applications for job-2 (AC Repair)
  const JobApplication(
    id: 'app-5',
    jobId: 'job-2',
    providerName: 'Cool Tech Services',
    providerService: 'AC Repair',
    providerInitial: 'C',
    providerRating: 4.7,
    providerReviewCount: 89,
    providerDistance: '2.0 km',
    providerExperience: '9 years',
    providerVerified: true,
    priceOffer: '\u20b91,200',
    message:
        'Likely a gas leak or compressor issue. I carry gas refill kit. If it\'s a part replacement, will provide quote first.',
    eta: '40 min',
    canStartNow: false,
    appliedTime: '45 min ago',
  ),
  const JobApplication(
    id: 'app-6',
    jobId: 'job-2',
    providerName: 'Ram AC Repair',
    providerService: 'AC Repair',
    providerInitial: 'R',
    providerRating: 4.3,
    providerReviewCount: 34,
    providerDistance: '1.5 km',
    providerExperience: '6 years',
    providerVerified: false,
    priceOffer: '\u20b9900',
    message:
        'Will check and fix your AC today evening. Gas refill included in price.',
    eta: '2 hours',
    canStartNow: false,
    appliedTime: '50 min ago',
  ),

  // Applications for job-4 (Tutor)
  const JobApplication(
    id: 'app-7',
    jobId: 'job-4',
    providerName: 'Deepak Mathur',
    providerService: 'Tutor',
    providerInitial: 'D',
    providerRating: 4.9,
    providerReviewCount: 42,
    providerDistance: '0.8 km',
    providerExperience: '15 years',
    providerVerified: true,
    priceOffer: '\u20b9900/hr',
    message:
        'MTech graduate. 15 years of CBSE maths teaching experience. 95% board results among my students.',
    eta: 'Can start Monday',
    canStartNow: false,
    appliedTime: '4 hours ago',
  ),
];

/// Helper: get applications for a specific job.
List<JobApplication> getApplicationsForJob(String jobId) {
  return dummyApplications.where((a) => a.jobId == jobId).toList();
}

/// Helper: get active job posts for user's "My Requests".
List<JobPost> getJobsByStatus(JobStatus status) {
  return dummyJobPosts.where((j) => j.status == status).toList();
}

/// Helper: get nearby open jobs for providers (by pincode).
List<JobPost> getNearbyOpenJobs(String pincode) {
  return dummyJobPosts
      .where(
        (j) =>
            j.status == JobStatus.active &&
            (j.pincode == pincode || _isNearbyPincode(j.pincode, pincode)),
      )
      .toList()
    ..sort((a, b) {
      // Urgent first
      if (a.urgency != b.urgency) {
        return a.urgency.index.compareTo(b.urgency.index);
      }
      return 0;
    });
}

bool _isNearbyPincode(String a, String b) {
  if (a.length < 3 || b.length < 3) return false;
  return a.substring(0, 3) == b.substring(0, 3);
}

/// Categories available for posting.
const List<String> jobCategories = [
  'Plumber',
  'Electrician',
  'AC Repair',
  'Cleaning',
  'Carpenter',
  'Painter',
  'Salon',
  'Tutor',
  'Bike Repair',
  'Appliance Repair',
  'Pest Control',
  'Gardening',
  'Other',
];
