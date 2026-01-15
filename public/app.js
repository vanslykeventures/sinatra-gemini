const ageOptions = {
  fall: {
    baseball: ["U7", "U9", "U11", "U13", "17U"],
    softball: ["U7", "U9", "U11", "U16"],
    "tee ball": [],
  },
  spring: {
    baseball: ["U8", "U10", "U12", "U14", "U18"],
    softball: ["U8", "U10", "U12", "U17"],
    "tee ball": [],
  },
};

const seasonGroup = document.getElementById("season");
const sportGroup = document.getElementById("sport");
const ageRangeFieldset = document.getElementById("age_range_fieldset");
const ageSelect = document.getElementById("age_range");
const ageHelp = document.getElementById("age_help");
const teeballLevelFieldset = document.getElementById("teeball_level_fieldset");
const form = document.getElementById("umpbot_form");
const resultBox = document.getElementById("result");
const loading = document.getElementById("loading");
const resultCard = document.getElementById("result_card");
const clearButton = document.getElementById("clear_form");

const selectedValue = (groupName) => {
  const checked = document.querySelector(`input[name="${groupName}"]:checked`);
  return checked ? checked.value : "";
};

const buildAgeOptions = () => {
  const season = selectedValue("season");
  const sport = selectedValue("sport");
  const ages = ageOptions[season]?.[sport] || [];
  const showTeeballLevel = season === "spring" && sport === "tee ball";
  const hasSelection = season && sport;

  ageSelect.innerHTML = "";
  if (!hasSelection) {
    ageRangeFieldset.classList.add("hidden");
    teeballLevelFieldset.classList.add("hidden");
    return;
  }

  if (ages.length === 0) {
    const option = document.createElement("option");
    option.value = "";
    option.textContent = "No age ranges for this selection";
    option.disabled = true;
    option.selected = true;
    ageSelect.append(option);
    ageSelect.disabled = true;
    ageHelp.textContent = "This selection does not have age-specific rules.";
    ageRangeFieldset.classList.toggle("hidden", showTeeballLevel);
    teeballLevelFieldset.classList.toggle("hidden", !showTeeballLevel);
    return;
  }

  const placeholder = document.createElement("option");
  placeholder.value = "";
  placeholder.textContent = "Select age range";
  placeholder.disabled = true;
  placeholder.selected = true;
  ageSelect.append(placeholder);

  ages.forEach((age) => {
    const option = document.createElement("option");
    option.value = age;
    option.textContent = age;
    ageSelect.append(option);
  });

  ageSelect.disabled = false;
  ageHelp.textContent = "";
  ageRangeFieldset.classList.remove("hidden");
  teeballLevelFieldset.classList.add("hidden");
};

const updateResult = (message) => {
  resultCard.classList.remove("hidden");
  resultBox.textContent = message;
};

seasonGroup.addEventListener("change", buildAgeOptions);
sportGroup.addEventListener("change", buildAgeOptions);
buildAgeOptions();

form.addEventListener("submit", async (event) => {
  event.preventDefault();
  loading.classList.add("active");
  updateResult("Loading...");
  const submitButton = form.querySelector('button[type="submit"]');
  submitButton.disabled = true;

  try {
    const response = await fetch(form.action, {
      method: "POST",
      body: new FormData(form),
    });
    const text = await response.text();
    updateResult(text.trim() || "No response returned.");
  } catch (error) {
    updateResult("Something went wrong. Please try again.");
  } finally {
    loading.classList.remove("active");
    submitButton.disabled = false;
  }
});

clearButton.addEventListener("click", () => {
  form.reset();
  buildAgeOptions();
  resultBox.textContent = "";
  resultCard.classList.add("hidden");
});
