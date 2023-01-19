USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Income].[IncomeBookFullView]', 'V ') IS NULL EXEC('CREATE VIEW [Income].[IncomeBookFullView]  AS SELECT 1')
GO
ALTER VIEW [Income].[IncomeBookFullView]
--WITH SCHEMABINDING
AS
	SELECT 
		IB_ID, IB_DATE,
		IB_ID_MASTER,
		CL_ID, CL_ID_MASTER, CL_NAME,
		VD_ID, VD_ID_MASTER, VD_NAME,
		HLF_ID, HLF_ID_MASTER, HLF_NAME,
		IB_PRICE, IB_SUM, IB_COUNT, IB_FULL_PAY, 
		PER_ID, PER_ID_MASTER, PER_NAME,
		IB_LOCK, IB_REPAY, IB_NOTE,
		(
			SELECT COUNT(*)
			FROM
				(
					SELECT IB_ID
					FROM
						Income.IncomeBook d
					WHERE d.IB_ID = a.IB_ID_MASTER
						AND d.IB_FULL_PAY IS NOT NULL

					UNION ALL

					SELECT IB_ID
					FROM
						Income.IncomeBook d
					WHERE a.IB_ID = d.IB_ID_MASTER
						AND d.IB_FULL_PAY IS NOT NULL

					UNION ALL

					SELECT IB_ID
					FROM
						Income.IncomeBook d
					WHERE a.IB_ID = d.IB_ID
						AND d.IB_FULL_PAY IS NOT NULL
				) AS o_O
		) AS IB_PAYED,
		CASE
			WHEN EXISTS	(
					SELECT b.IB_ID
					FROM 
						Income.IncomeBook b
					WHERE b.IB_ID_MASTER = a.IB_ID
				) THEN CAST(0 AS BIT)
				ELSE CAST(1 AS BIT)
		END AS IB_REPAYED
	FROM
		Income.IncomeBookView a LEFT OUTER JOIN
		Personal.PersonalDetail ON PER_ID_MASTER = IB_ID_PERSONALGO
