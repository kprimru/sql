﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DistrCoefRound]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[DistrCoefRound] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE OR ALTER FUNCTION [dbo].[DistrCoefRound]
(
	@SYS	INT,
	@NET	INT,
	@TYPE	NVARCHAR(128),
	@DATE	SMALLDATETIME
)
RETURNS INT
AS
BEGIN
	DECLARE @RES INT

	DECLARE @PERIOD	UNIQUEIDENTIFIER

	SELECT @PERIOD = ID
	FROM Common.Period
	WHERE @DATE BETWEEN START_REPORT AND FINISH_REPORT AND TYPE = 2


	SELECT @RES = RND
	FROM
		dbo.DistrTypeCoef b
	WHERE ID_MONTH = @PERIOD AND ID_NET = @NET

	RETURN @RES
END
GO
