USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[RegComplectGet]', 'FN') IS NULL EXEC('CREATE FUNCTION [Reg].[RegComplectGet] () RETURNS Int AS BEGIN RETURN NULL END')
GO
ALTER FUNCTION [Reg].[RegComplectGet]
(
	@HOST	SmallInt,
	@DISTR	Int,
	@COMP	TinyInt,
	@DATE	DateTime
)
RETURNS VarChar(50)
AS
BEGIN
	DECLARE @RES VarChar(50)

	IF NOT EXISTS
		(
			SELECT *
			FROM Reg.RegHistory
		)
	BEGIN
		SELECT TOP 1 @RES = Complect
		FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
		WHERE a.DistrNumber = @DISTR AND a.CompNumber = @COMP AND a.HostID = @HOST
	END
	ELSE
	BEGIN
		SELECT TOP 1 @RES = COMPLECT
		FROM Reg.RegHistory
		INNER JOIN Din.SystemType ON ID_TYPE = SST_ID
		WHERE DATE <= @DATE
			AND ID_DISTR =
				(
					SELECT ID
					FROM Reg.RegDistr
					WHERE ID_HOST = @HOST
						AND DISTR = @DISTR
						AND COMP = @COMP
				)
			AND COMPLECT IS NOT NULL
			AND SST_COMPLECT = 1
		ORDER BY DATE DESC
	END

	RETURN @RES
END
GO
