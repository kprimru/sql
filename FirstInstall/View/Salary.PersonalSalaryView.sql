USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Salary].[PersonalSalaryView]
--WITH SCHEMABINDING
AS 
	SELECT 
		a.PS_ID, 	
		PER_ID, PER_ID_MASTER, PER_NAME,
		VD_ID, VD_ID_MASTER, VD_NAME,
		PS_DATE,
		b.PR_ID, b.PR_ID_MASTER, b.PR_NAME,
		PS_SALARY, PS_LOCK,
		(
			SELECT SUM(PSD_TOTAL)
			FROM Salary.PersonalSalaryDetailView b
			WHERE a.PS_ID = b.PS_ID
		) AS PSD_TOTAL,
		(
			SELECT SUM(PSB_TOTAL)
			FROM Salary.PersonalSalaryBookView c
			WHERE a.PS_ID = c.PS_ID
		) AS PSB_TOTAL,
		(
			SELECT SUM(PSB_DELIVERY)	
			FROM Salary.PersonalSalaryBookView c
			WHERE a.PS_ID = c.PS_ID
		) AS PSB_DELIVERY,
		(
			SELECT SUM(PSB_COUNT)	
			FROM Salary.PersonalSalaryBookView c
			WHERE a.PS_ID = c.PS_ID
		) AS PS_BOOK_COUNT,
		/*
		SUM(PSD_TOTAL) AS PSD_TOTAL,
		SUM(PSB_TOTAL) AS PSB_TOTAL,
		SUM(PSB_DELIVERY) AS PSB_DELIVERY,
		SUM(PSB_COUNT) AS PS_BOOK_COUNT,
		*/
		PS_BOOK_NORM, 
		CP_ID_MASTER, CP_NAME, CP_BONUS AS PS_BOOK_BONUS,
		PS_CORRECT, PS_COMMENT, PS_PAYED, PS_DEBT,
		c.PR_ID AS PR_PAY_ID, c.PR_NAME AS PR_PAY_NAME, c.PR_ID_MASTER AS PR_PAY_ID_MASTER 
	FROM
		Salary.PersonalSalary a	INNER JOIN
		Personal.PersonalLast 	ON	PER_ID_MASTER	=	PS_ID_PERSONAL INNER JOIN 
		Clients.VendorLast ON VD_ID_MASTER = PS_ID_VENDOR INNER JOIN
		Common.PeriodLast	b	ON	PR_ID_MASTER	=	PS_ID_PERIOD	LEFT OUTER JOIN
		/*Salary.PersonalSalaryBookView b ON a.PS_ID = b.PS_ID LEFT OUTER JOIN
		Salary.PersonalSalaryDetailView c ON a.PS_ID = c.PS_ID LEFT OUTER JOIN*/
		Book.CompetitionLast ON CP_ID_MASTER = PS_ID_COMPETITION  LEFT OUTER JOIN
		Common.PeriodLast c ON c.PR_ID_MASTER = PS_ID_PAY
	
		