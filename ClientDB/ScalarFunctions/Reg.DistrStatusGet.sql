﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[DistrStatusGet]', 'FN') IS NULL EXEC('CREATE FUNCTION [Reg].[DistrStatusGet] () RETURNS Int AS BEGIN RETURN NULL END')
GO
ALTER FUNCTION [Reg].[DistrStatusGet]
(
	@HOST	INT,
	@DISTR	INT,
	@COMP	TINYINT,
	@DATE	DATETIME
)
RETURNS INT
AS
BEGIN
	DECLARE @RES INT

	DECLARE @DIS_ID	UNIQUEIDENTIFIER

	SELECT @DIS_ID = ID
	FROM Reg.RegDistr
	WHERE ID_HOST = @HOST AND DISTR = @DISTR AND COMP = @COMP

	IF @DIS_ID IS NULL
	BEGIN
		SELECT @RES = Service
		FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
		WHERE a.HostID = @HOST AND DistrNumber = @DISTR AND CompNumber = @COMP
	END
	ELSE
	BEGIN
		SELECT TOP 1 @RES = DS_REG
		FROM
			Reg.RegHistory
			INNER JOIN dbo.DistrStatus ON DS_ID = ID_STATUS
		WHERE ID_DISTR = @DIS_ID AND DATE <= @DATE
		ORDER BY DATE DESC
	END

	RETURN @RES
END
GO
