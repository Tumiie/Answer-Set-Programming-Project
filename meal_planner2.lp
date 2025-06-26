%Tumelo Matobo - Automated Meal Planner using ASP

% Define the meal portion sizes in grams
portion(50). %50 grams
portion(100). %100 grams
portion(150). %150 grams
portion(200). %200 grams

%These can be uncommented to get more answer sets of valid meals
%portion(250). %250 grams
%portion(300). %300 grams

% Define the staples with calories, proteins, carbohydrates, fats (per 100g)
staple(papa, 365, 7, 78, 1).
staple(likhobe, 329, 11, 72, 3).
staple(wheat_porridge, 340, 13, 75, 3).
staple(samp_and_beans, 142, 7, 25, 1).

% Define the vegetables with calories, proteins, carbohydrates, fats (per 100g)
veggies(moroho, 36, 3, 7, 0).
veggies(cabbage, 25, 1, 6, 0).
veggies(root_vegetables, 41, 1, 10, 0).
veggies(liperekisi, 50, 1, 10, 0).

% Define the protein sources with calories, proteins, carbohydrates, fats (per 100g)
protein(beans, 347, 22, 62, 2).
protein(nama_ea_khomo, 250, 26, 0, 17).
protein(nama_ea_nku, 294, 25, 0, 21).
protein(nama_ea_khoho, 239, 27, 0, 14).

% Choose and assign one food item from each category to a meal and their varied portion sizes
1 {
    meal(S, PS, V, PV, PR, PPR) :
        staple(S, _, _, _, _),
        portion(PS),
        veggies(V, _, _, _, _),
        portion(PV),
        protein(PR, _, _, _, _),
        portion(PPR)
} 1.

% Calculate the total grams of proteins, carbs, and fat for a meal
meal_nutrientsSum(S, PS, V, PV, PR, PPR, ProSum, CarbSum, FatSum) :-
    meal(S, PS, V, PV, PR, PPR),
    staple(S, _, P1, CH1, F1),
    veggies(V, _, P2, CH2, F2),
    protein(PR, _, P3, CH3, F3),
    ProSum = (P1 * PS + P2 * PV + P3 * PPR) / 100,
    CarbSum = (CH1 * PS + CH2 * PV + CH3 * PPR) / 100,
    FatSum = (F1 * PS + F2 * PV + F3 * PPR) / 100.

% Convert the macronutrient grams to calories
%1gram protein = 4kcal, 1gram carbohydrate = 4kcal, 1 gram fat = 9 kcal
macro_calories(S, PS, V, PV, PR, PPR, ProCal, CarbCal, FatCal) :-
    meal_nutrientsSum(S, PS, V, PV, PR, PPR, ProSum, CarbSum, FatSum),
    ProCal = ProSum * 4,
    CarbCal = CarbSum * 4,
    FatCal = FatSum * 9.

% Compute the total meal calories from macronutrient calories
meal_caloriesSum(S, PS, V, PV, PR, PPR, TotCal) :-
    macro_calories(S, PS, V, PV, PR, PPR, ProCal, CarbCal, FatCal),
    TotCal = ProCal + CarbCal + FatCal.

%Compute the macronutrient percentage contributions
macro_percentages(S, PS, V, PV, PR, PPR, ProPercent, CarbPercent, FatPercent) :-
    macro_calories(S, PS, V, PV, PR, PPR, ProCal, CarbCal, FatCal),
    meal_caloriesSum(S, PS, V, PV, PR, PPR, TotCal),
    ProPercent = (ProCal * 100) / TotCal,
    CarbPercent = (CarbCal * 100) / TotCal,
    FatPercent = (FatCal * 100) / TotCal.

% The macronutrient percentage constraints
carb_min(40). %Minimum 40% carbs
carb_max(50). %Maximum 50% carbs
protein_min(24). %Minimum 24% proteins
protein_max(26). %Maximum 26% proteins
fat_min(25).  %Minimum 25% fats
fat_max(30). %Maximum 30% fats

%Set a calorie range per meal
calorie_min(600). %This is the minimum calories per meal
calorie_max(900). %This is the maximum calories per meal

%Reject meals with calories below or above limits
:- meal(S, PS, V, PV, PR, PPR), meal_caloriesSum(S, PS, V, PV, PR, PPR, TotCal), calorie_min(Min), Min > TotCal. 
:- meal(S, PS, V, PV, PR, PPR), meal_caloriesSum(S, PS, V, PV, PR, PPR, TotCal), calorie_max(Max), TotCal > Max.
%Reject meals outside carb percentage range
:- meal(S, PS, V, PV, PR, PPR),macro_percentages(S, PS, V, PV, PR, PPR, ProPercent, CarbPercent, FatPercent), carb_min(CarbMin), CarbMin > CarbPercent.
:- meal(S, PS, V, PV, PR, PPR),macro_percentages(S, PS, V, PV, PR, PPR, ProPercent, CarbPercent, FatPercent), carb_max(CarbMax), CarbPercent > CarbMax.
%Reject meals outside protein percentage range
:- meal(S, PS, V, PV, PR, PPR),macro_percentages(S, PS, V, PV, PR, PPR, ProPercent, CarbPercent, FatPercent), protein_min(ProteinMin), ProteinMin > ProPercent.
:- meal(S, PS, V, PV, PR, PPR),macro_percentages(S, PS, V, PV, PR, PPR, ProPercent, CarbPercent, FatPercent), protein_max(ProteinMax), ProPercent > ProteinMax.
%Reject meals outside fat percentage range
:- meal(S, PS, V, PV, PR, PPR),macro_percentages(S, PS, V, PV, PR, PPR, ProPercent, CarbPercent, FatPercent), fat_min(FatMin), FatMin > FatPercent.
:- meal(S, PS, V, PV, PR, PPR),macro_percentages(S, PS, V, PV, PR, PPR, ProPercent, CarbPercent, FatPercent), fat_max(FatMax), FatPercent > FatMax.

%Use selected_meals to prevent atoms accumulating across answer sets
selected_meal(S, PS, V, PV, PR, PPR) :- meal(S, PS, V, PV, PR, PPR).

% Show only valid meals
valid_meal(S, PS, V, PV, PR, PPR, TotCal, ProPercent, CarbPercent, FatPercent) :-
    selected_meal(S, PS, V, PV, PR, PPR),
    macro_percentages(S, PS, V, PV, PR, PPR, ProPercent, CarbPercent, FatPercent),
    meal_caloriesSum(S, PS, V, PV, PR, PPR, TotCal).

#show valid_meal/10.
