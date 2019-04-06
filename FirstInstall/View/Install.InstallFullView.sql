USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Install].[InstallFullView]
--WITH SCHEMABINDING
AS
SELECT
		a.INS_ID, INS_DATE, IN_ID, ID_ID, IN_DATE, ID_COMMENT, ID_LOCK,
		VD_ID, VD_ID_MASTER, VD_NAME,
		CL_ID, CL_ID_MASTER, CL_NAME,
		SYS_ID, SYS_ID_MASTER, SYS_SHORT, 
		DT_ID, DT_ID_MASTER, DT_NAME, DT_SHORT,
		NT_ID, NT_ID_MASTER, NT_NAME, 
		TT_ID, TT_ID_MASTER, TT_NAME, 		
		IND_ID, IND_LOCK, IND_BOX_DATE,
		IND_ACT_DATE, IND_ACT_RETURN,				
		IND_DISTR, IND_CLAIM,
		NT_NEW_NAME,
		CAST(CASE 
			WHEN ID_FULL_DATE IS NULL THEN 0
			ELSE 1
		END AS BIT) AS ID_FULL_PAY,
		PER_ID, PER_ID_MASTER, PER_NAME, 
		IND_INSTALL_DATE,		
		IND_CONTRACT, CLM_ID, CLM_DATE,		
		REVERSE(STUFF(REVERSE((
			SELECT '' + IC_TEXT + CHAR(10)
			FROM Install.InstallComments
			WHERE IC_ID_IND = IND_ID
			ORDER BY IC_DATE DESC FOR XML PATH('')
		)), 1, 1, '')) AS IND_COMMENTS, 
		ID_RESTORE, ID_EXCHANGE,
		IA_ID_MASTER, IA_ID, IA_NAME, IA_NORM, IND_ACT_SIGN, IND_ACT_MAIL, IND_ACT_NOTE,
		IND_TO_NUM, IND_LIMIT, IND_ARCHIVE,
		(
			SELECT TOP 1 ID_PERSONAL
			FROM Income.IncomeFullView z
			WHERE z.ID_ID = b.ID_ID
		) AS ID_PERSONAL
	FROM 
		Install.InstallMasterView a WITH(NOEXPAND) INNER JOIN
		Install.InstallDetailFullView b ON a.INS_ID = b.INS_ID
