USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Income].[INCOME_WEIGHT_REPORT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@TYPE	UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		IN_DATE, CL_NAME, SYS_SHORT, DT_NAME, NT_NEW_NAME, ID_FULL_DATE, ID_PERSONAL, 
		(
			SELECT WG_VALUE
			FROM Distr.WeightActive
			WHERE WG_ID_SYSTEM = SYS_ID_MASTER
		) * NT_COEF * TT_WEIGHT AS WEIGHT
	FROM 
		Income.IncomeFullView a
		INNER JOIN Distr.NetTypeDetail b ON a.NT_ID = b.NT_ID
		INNER JOIN Distr.TechTypeDetail c ON a.TT_ID = c.TT_ID
	WHERE (IN_DATE >= @BEGIN OR @BEGIN IS NULL) 
		AND (IN_DATE <= @END OR @END IS NULL)
		AND (@TYPE IS NULL OR EXISTS(
					SELECT * 
					FROM 
						Income.IncomePersonal z 
						INNER JOIN Personal.PersonalAll ON IP_ID_PERSONAL = PER_ID_MASTER 
					WHERE PER_ID_TYPE = @TYPE AND IP_ID_INCOME = ID_ID
					)
			)
		AND SYS_MAIN = 1
		AND ID_RESTORE = 0 
		AND ID_EXCHANGE = 0 
		AND ID_REPAY = 0
		AND DT_NAME NOT IN ('����. ������', '�������� ����.������')
	ORDER BY IN_DATE DESC, CL_NAME		
END
