USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[SYSTEM_WEIGHT]
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Distr.SystemTypeWeight(STW_ID_SYSTEM, STW_ID_TYPE, STW_WEIGHT)
		SELECT
			SYS_ID_MASTER, DT_ID_MASTER, SYS_WEIGHT
		FROM Distr.SystemActive, Distr.DistrTypeActive
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Distr.SystemTypeWeight
				WHERE STW_ID_SYSTEM = SYS_ID_MASTER AND STW_ID_TYPE = DT_ID_MASTER
			)

	UPDATE t
	SET STW_WEIGHT = SYS_WEIGHT
	FROM
		Distr.SystemTypeWeight t INNER JOIN
		Distr.SystemActive ON SYS_ID_MASTER = STW_ID_SYSTEM

	UPDATE Distr.SystemTypeWeight
	SET	STW_WEIGHT = 1
	WHERE STW_ID_TYPE IN
		(
			'a17d355f-8202-e011-b173-000c2986905f',
			'1a3cb75e-0fba-df11-b163-000c2986905f',
			'0e3cb75e-0fba-df11-b163-000c2986905f',
			'0c3cb75e-0fba-df11-b163-000c2986905f'
		)
END
GO
