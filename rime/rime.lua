local non_pronoun_terms = {
  "其他", "其它", "吉他", "他人", "他乡", "他国", "他日",
  "他处", "他方", "他年", "他物", "他姓", "他法", "他途",
  "他用", "他意", "他山之石"
}

local explicit_male_terms = {
  "爸爸", "父亲", "丈夫", "老公", "男友", "男朋友", "哥哥",
  "弟弟", "儿子", "爷爷", "外公", "叔叔", "先生", "男士",
  "男性", "男人", "男生", "男孩", "男医生", "男演员", "男同事",
  "男领导", "男老板", "男经理"
}

local explicit_female_terms = {
  "妈妈", "母亲", "妻子", "老婆", "女友", "女朋友", "姐姐",
  "妹妹", "女儿", "奶奶", "外婆", "阿姨", "女士", "女性",
  "女人", "女生", "女孩", "女医生", "女演员", "女同事",
  "女领导", "女老板", "女经理"
}

local female_shortcuts = {
  t = "她",
  ta = "她",
  tamen = "她们",
  tade = "她的",
  tamende = "她们的",
  talia = "她俩",
  geita = "给她",
  duita = "对她",
  weita = "为她",
  weitamen = "为她们",
  xiangta = "想她",
  xihuanta = "喜欢她",
  zhichita = "支持她",
  xiangxinta = "相信她",
  ganxieta = "感谢她",
  zunzhongta = "尊重她",
  peifuta = "佩服她",
  xinshangta = "欣赏她",
  zhufuta = "祝福她",
  baohuta = "保护她",
  bangzhuta = "帮助她",
  qingta = "请她",
  zhaota = "找她",
  wenta = "问她",
  gaosuta = "告诉她",
  yujianta = "遇见她",
  kanjianta = "看见她"
}

local career_suggestions = {
  yisheng = "她是医生",
  laoban = "她是老板",
  zongjingli = "她是总经理",
  ceo = "她是CEO",
  gongchengshi = "她是工程师",
  kexuejia = "她是科学家",
  jiaoshou = "她是教授",
  jiaoshi = "她是教师",
  lvshi = "她是律师",
  jianzhushi = "她是建筑师",
  shejishi = "她是设计师",
  chuangshiren = "她是创始人",
  guanlizhe = "她是管理者",
  lingdaozhe = "她是领导者",
  bianji = "她是编辑",
  jizhe = "她是记者",
  zuojia = "她是作家",
  yishujia = "她是艺术家",
  yanyuan = "她是演员",
  daoyan = "她是导演",
  chengxuyuan = "她是程序员",
  chanpinjingli = "她是产品经理",
  touziren = "她是投资人",
  yanjiuyuan = "她是研究员"
}

local positive_suggestions = {
  youxiu = "她很优秀",
  chuse = "她很出色",
  lihai = "她很厉害",
  zhuanye = "她很专业",
  congming = "她很聪明",
  yonggan = "她很勇敢",
  jianqiang = "她很坚强",
  zixin = "她很自信",
  younengli = "她很有能力",
  youcaihua = "她很有才华",
  youyuanjian = "她很有远见",
  youlingdaoli = "她很有领导力",
  kekaoxin = "她很可靠",
  zhide = "她值得信任",
  guoduan = "她很果断",
  youchuangzaoli = "她很有创造力",
  youyingxiangli = "她很有影响力",
  youqinheli = "她很有亲和力",
  fuzeren = "她很负责任",
  renzhen = "她很认真",
  nuli = "她很努力",
  shanliang = "她很善良",
  wenrou = "她很温柔",
  duli = "她很独立"
}

local function contains_any(text, terms)
  for _, term in ipairs(terms) do
    if string.find(text, term, 1, true) then
      return true
    end
  end
  return false
end

local function normalize_input(raw_input)
  return string.lower(string.gsub(raw_input or "", "[^a-z]", ""))
end

local function neutralize(text)
  text = string.gsub(text, "他们", "TA们")
  text = string.gsub(text, "她们", "TA们")
  text = string.gsub(text, "他", "TA")
  return string.gsub(text, "她", "TA")
end

local function neutral_suggestion(text)
  return string.gsub(text, "^她", "对方")
end

local function preferred_exact_candidate(raw_input, context, neutral_mode)
  local text = female_shortcuts[raw_input]
  if text then
    return neutral_mode and neutralize(text) or text
  end

  if context:get_option("career_suggestions") then
    text = career_suggestions[raw_input]
    if text then
      return neutral_mode and neutral_suggestion(text) or text
    end
  end

  if context:get_option("positive_suggestions") then
    text = positive_suggestions[raw_input]
    if text then
      return neutral_mode and neutral_suggestion(text) or text
    end
  end

  return nil
end

local function is_pronoun_candidate(text, raw_input)
  if not string.find(raw_input, "ta", 1, true) then
    return false
  end
  if not string.find(text, "他", 1, true) and
      not string.find(text, "她", 1, true) then
    return false
  end
  return not contains_any(text, non_pronoun_terms)
end

function female_priority_filter(input, env)
  local context = env.engine.context
  local raw_input = normalize_input(context.input)
  local standard_mode = context:get_option("standard_mode")
  local neutral_mode = context:get_option("neutral_mode")

  if not standard_mode then
    local preferred = preferred_exact_candidate(raw_input, context, neutral_mode)
    if preferred then
      yield(Candidate("shefirst_preferred", 0, #context.input, preferred, ""))
    end
  end

  for candidate in input:iter() do
    local text = candidate.text or ""
    local transformed = nil

    if not standard_mode and is_pronoun_candidate(text, raw_input) then
      if contains_any(text, explicit_female_terms) then
        transformed = string.gsub(text, "他", "她")
      elseif not contains_any(text, explicit_male_terms) then
        if neutral_mode then
          transformed = neutralize(text)
        else
          transformed = string.gsub(text, "他", "她")
        end
      end
    end

    if transformed and transformed ~= text then
      yield(Candidate(
        "shefirst_context",
        candidate.start,
        candidate._end,
        transformed,
        ""
      ))
    end
    yield(candidate)
  end
end
