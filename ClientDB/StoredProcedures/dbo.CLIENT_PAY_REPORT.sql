USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_PAY_REPORT]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		DistrStr,
		c.LAST_ACT,
		c.LAST_PAY_MON,
		/*c.NEXT_MONTH AS 'ближайшие незакрытый мес€ц', */
		c.PAY_DELTA,
		c.LAST_BILL_SUM
	FROM 
		dbo.ClientDistrView a WITH(NOEXPAND)
		INNER JOIN dbo.ClientTable b ON a.ID_CLIENT = b.ClientID
		LEFT OUTER JOIN dbo.DBFDistrLastPayView c ON c.SYS_REG_NAME = a.SystemBaseName
															AND c.DIS_NUM = a.DISTR
															AND c.DIS_COMP_NUM = a.COMP
	WHERE b.ClientID = @ID
		AND DS_REG = 0
	ORDER BY SystemOrder, DISTR, COMP
END
