USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[BillDistrSync]
   ON  [dbo].[BillDistrTable]
   AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @Distrs Table
    (
		SYS_REG_NAME	VarChar(20),
		DIS_NUM			Int,
		DIS_COMP_NUM	TinyInt,
		PR_DATE			SmallDateTime,
		Primary Key Clustered (DIS_NUM, SYS_REG_NAME, PR_DATE, DIS_COMP_NUM)
    );

    INSERT INTO @Distrs
	SELECT DISTINCT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE
	FROM
	(
		SELECT BD_ID_DISTR, BL_ID_PERIOD
		FROM inserted
		INNER JOIN dbo.BillTable ON BL_ID = BD_ID_BILL

		UNION

		SELECT BD_ID_DISTR, BL_ID_PERIOD
		FROM deleted
		INNER JOIN dbo.BillTable ON BL_ID = BD_ID_BILL
	) T
	INNER JOIN dbo.DistrTable D ON D.DIS_ID = T.BD_ID_DISTR
	INNER JOIN dbo.SystemTable S ON S.SYS_ID = D.DIS_ID_SYSTEM
	INNER JOIN dbo.PeriodTable P ON P.PR_ID = T.BL_ID_PERIOD;

	UPDATE S
	SET UPD_DATE = GetDate()
	FROM Sync.DistrFinancing	S
	INNER JOIN @Distrs			D ON	D.SYS_REG_NAME	= S.SYS_REG_NAME
									AND	D.DIS_NUM		= S.DIS_NUM
									AND D.DIS_COMP_NUM	= S.DIS_COMP_NUM
									AND D.PR_DATE		= S.PR_DATE;

	INSERT INTO Sync.DistrFinancing(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE)
	SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE
	FROM @Distrs D
	WHERE NOT EXISTS
		(
			SELECT *
			FROM Sync.DistrFinancing S
			WHERE	D.SYS_REG_NAME	= S.SYS_REG_NAME
				AND	D.DIS_NUM		= S.DIS_NUM
				AND D.DIS_COMP_NUM	= S.DIS_COMP_NUM
				AND D.PR_DATE		= S.PR_DATE
		);
END


GO
