USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Complect@Extract]
(
	@Complect	VarChar(100)
)
RETURNS TABLE
AS
RETURN 
(
	SELECT TOP (1) S.HostId, DistrNumber, CompNumber
	FROM dbo.RegNodeTable		R
	INNER JOIN dbo.SystemTable	S ON R.SystemName = S.SystemBaseName
	WHERE	@Complect LIKE R.SystemName + '%' + Cast(DistrNumber AS VarChar(20)) + '%'
		AND Complect = @Complect
)
