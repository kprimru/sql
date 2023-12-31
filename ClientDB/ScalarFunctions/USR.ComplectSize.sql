USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [USR].[ComplectSize]
(
	@ID	INT
)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @RES VARCHAR(100)

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

	SELECT @RES = dbo.FileByteSizeToStr(SZ)
	FROM
		(
			SELECT SUM(IBS_SIZE) AS SZ
			FROM
				dbo.InfoBankSizeView WITH(NOEXPAND)
				INNER JOIN USR.USRIB ON UI_ID_BASE = IBF_ID_IB
			WHERE IBS_DATE = @DT AND UI_ID_USR = @ID
		) AS o_O

	RETURN @RES
END
GO
