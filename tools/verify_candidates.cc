#include <iostream>
#include <string>
#include <vector>

#include "rime_api.h"

void rime_require_module_lua();

enum class Mode {
  Female,
  Neutral,
  Standard,
};

struct TestCase {
  const char* input;
  const char* expected;
  Mode mode = Mode::Female;
  bool career_suggestions = true;
  bool positive_suggestions = true;
};

const char* mode_name(Mode mode) {
  switch (mode) {
    case Mode::Female:
      return "female";
    case Mode::Neutral:
      return "neutral";
    case Mode::Standard:
      return "standard";
  }
}

int main(int argc, char** argv) {
  if (argc != 4) {
    std::cerr << "usage: verify_candidates <shared> <user> <staging>\n";
    return 2;
  }

  rime_require_module_lua();
  RimeApi* rime = rime_get_api();

  RIME_STRUCT(RimeTraits, traits);
  traits.shared_data_dir = argv[1];
  traits.user_data_dir = argv[2];
  traits.staging_dir = argv[3];
  traits.prebuilt_data_dir = argv[3];
  traits.distribution_name = "SheFirst";
  traits.distribution_code_name = "shefirst";
  traits.distribution_version = "1.1.0";
  traits.app_name = "rime.shefirst.verify";
  traits.min_log_level = 2;
  traits.log_dir = "";

  rime->setup(&traits);
  rime->initialize(&traits);

  const std::vector<TestCase> tests = {
      {"t", "她"},
      {"ta", "她"},
      {"tamen", "她们"},
      {"tade", "她的"},
      {"geita", "给她"},
      {"henxiangta", "很想她"},
      {"tahenyouxiu", "她很优秀"},
      {"tahenchuse", "她很出色"},
      {"tamenhenzhuanye", "她们很专业"},
      {"yisheng", "她是医生"},
      {"ceo", "她是CEO"},
      {"youxiu", "她很优秀"},
      {"tashiwodebaba", "他是我的爸爸"},
      {"tashiwodemama", "她是我的妈妈"},
      {"qita", "其他"},
      {"jita", "吉他"},
      {"ta", "TA", Mode::Neutral},
      {"tamen", "TA们", Mode::Neutral},
      {"henxiangta", "很想TA", Mode::Neutral},
      {"yisheng", "对方是医生", Mode::Neutral},
      {"youxiu", "对方很优秀", Mode::Neutral},
      {"tashiwodebaba", "他是我的爸爸", Mode::Neutral},
      {"tashiwodemama", "她是我的妈妈", Mode::Neutral},
      {"ta", "他", Mode::Standard},
      {"yisheng", "医生", Mode::Standard},
      {"yisheng", "医生", Mode::Female, false, true},
      {"youxiu", "优秀", Mode::Female, true, false},
  };

  bool all_passed = true;
  for (const auto& test : tests) {
    RimeSessionId session = rime->create_session();
    if (!session || !rime->select_schema(session, "shefirst")) {
      std::cerr << "failed to create SheFirst session\n";
      all_passed = false;
      break;
    }
    rime->set_option(session, "zh_simp", True);
    rime->set_option(session, "shefirst_mode",
                     test.mode == Mode::Female ? True : False);
    rime->set_option(session, "neutral_mode",
                     test.mode == Mode::Neutral ? True : False);
    rime->set_option(session, "standard_mode",
                     test.mode == Mode::Standard ? True : False);
    rime->set_option(session, "career_suggestions",
                     test.career_suggestions ? True : False);
    rime->set_option(session, "positive_suggestions",
                     test.positive_suggestions ? True : False);
    rime->simulate_key_sequence(session, test.input);

    std::string first;
    RimeCandidateListIterator iterator = {0};
    if (rime->candidate_list_begin(session, &iterator)) {
      if (rime->candidate_list_next(&iterator) && iterator.candidate.text) {
        first = iterator.candidate.text;
      }
      rime->candidate_list_end(&iterator);
    }

    const bool passed = first == test.expected;
    std::cout << (passed ? "PASS" : "FAIL") << " ["
              << mode_name(test.mode) << "] " << test.input << " -> "
              << first << " (expected " << test.expected << ")\n";
    all_passed = all_passed && passed;
    rime->destroy_session(session);
  }

  rime->finalize();
  return all_passed ? 0 : 1;
}
