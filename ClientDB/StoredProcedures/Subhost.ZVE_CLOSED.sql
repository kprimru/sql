USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[ZVE_CLOSED]
	@SUBHOST	NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ClientName, DistrStr, NT_SHORT , SST_SHORT
	FROM dbo.RegNodeComplectClientView a
	WHERE a.DS_REG = 0
		AND NOT EXISTS
		(
			SELECT *
			FROM dbo.ExpDistr b
			WHERE a.HostID = b.ID_HOST
				AND a.DistrNumber = b.DISTR
				AND a.CompNumber = b.COMP
				AND b.STATUS = 1
				AND b.UNSET_DATE IS NULL
		)
		--AND SST_SHORT NOT IN ('дхс', 'юдл', 'дяо', 'кяб', 'ндд')
		AND NT_SHORT NOT IN ('нбо', 'нбох', 'нбл1', 'нбл2', 'нбй')
		AND SubhostName = @SUBHOST
	ORDER BY ClientName
END
