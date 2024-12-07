EXPLAIN
SELECT students.name, gpas.gpa AS gpa, sum(scores.score) AS total_score
FROM students, scores, gpas
WHERE students.id = scores.student_id AND students.id = gpas.student_id
GROUP BY students.id, gpas.student_id;
