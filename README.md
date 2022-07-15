# upo_professors_retrieve
Professor information retrieval tool for the Pablo de Olavide University (so far it works for the department of Molecular Biology and Biochemical Engineering)

# Run
Move to the folder and execute

bash osint.sh | tee "log$(date +%d_%m_%Y)"

# Output
Quoted tabular-separated fields are located by columns in this order: surname, name, area, category, email, phone, office. The results are appended to the file "results". 
