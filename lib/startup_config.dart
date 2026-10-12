/// Start-flow switch.
///
/// true  -> logged-in users land on "Choose Your Path". Tapping DSA World opens
///          the DSA World home screen directly (no Skill Quest, theme picker
///          or level map).
/// false -> the original flow (Skill Quest -> Theme -> Level map).
const bool kSkipStartupSteps = true;
