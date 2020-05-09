USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [USR].[ComplectSizeMB]
(
	@ID	INT
)
RETURNS BIGINT
AS
BEGIN
	DECLARE @RES BIGINT

	DECLARE @DT	DATETIME

	SELECT @DT = dbo.DateOf(UF_DATE)
	FROM USR.USRFile
	WHERE UF_ID = @ID

	IF NOT EXISTS
		(
			SELECT *
			FROM dbo.InfoBankSizeView WITH(NOEXPAND)
			WHERE IBS_DATE = @DT
		)
		SELECT @DT = MAX(IBS_DATE)
		FROM dbo.InfoBankSizeView WITH(NOEXPAND)
		WHERE IBS_DATE < @DT

	SELECT @RES = SUM(IBS_SIZE)
	FROM
		dbo.InfoBankSizeView WITH(NOEXPAND)
		INNER JOIN USR.USRIB ON UI_ID_BASE = IBF_ID_IB
	WHERE IBS_DATE = @DT AND UI_ID_USR = @ID

	SET @RES = @RES / 1024 / 1024

	RETURN @RES
END
GO
