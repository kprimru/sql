USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Reg].[RegComplectGet]
(
	@HOST	INT,
	@DISTR	INT,
	@COMP	TINYINT,
	@DATE	DATETIME
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @RES VARCHAR(50)

	IF NOT EXISTS
		(
			SELECT *
			FROM Reg.RegHistory			
		)
	BEGIN
		SELECT TOP 1 @RES = Complect
		FROM 
			dbo.RegNodeTable a
			INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
		WHERE a.DistrNumber = @DISTR AND a.CompNumber = @COMP AND b.HostID = @HOST
	END
	ELSE
	BEGIN
		SELECT TOP 1 @RES = COMPLECT
		FROM 
			Reg.RegHistory
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