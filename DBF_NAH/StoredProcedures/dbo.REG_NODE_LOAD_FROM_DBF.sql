USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REG_NODE_LOAD_FROM_DBF]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM RegNodeTable

	INSERT INTO RegNodeTable
		SELECT *
		FROM DBF.dbo.RegNodeTable
		WHERE (RN_COMMENT LIKE '(�)%' OR RN_COMMENT LIKE '(�1)%')

	UPDATE dbo.ClientDistrTable
	SET CD_REG_DATE = RN_REG_DATE
	FROM
		dbo.ClientDistrTable INNER JOIN
		dbo.DistrView ON DIS_ID = CD_ID_DISTR INNER JOIN
		dbo.RegNodeTable ON RN_SYS_NAME = SYS_REG_NAME AND
							RN_DISTR_NUM = DIS_NUM AND
							RN_COMP_NUM = DIS_COMP_NUM
	WHERE CD_REG_DATE IS NULL

	EXEC [dbo].[DISTR_BUH_CHANGE]
END
GO