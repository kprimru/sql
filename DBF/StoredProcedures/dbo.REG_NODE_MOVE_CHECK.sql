USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:			
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[REG_NODE_MOVE_CHECK]
	@periodid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @HOST SMALLINT
	SELECT @HOST = HST_ID
	FROM dbo.HostTable
	WHERE HST_REG_NAME = 'LAW'

	DECLARE @ERR NVARCHAR(MAX)

	SELECT @ERR = 
	(
		SELECT '����������� ��� ������� "' + SYS_SHORT_NAME + ' (' + SST_CAPTION + ' :: ' + SNC_SHORT + '"' + CHAR(10)
		FROM
		(
			SELECT DISTINCT REG_ID_SYSTEM, REG_ID_TYPE, REG_ID_NET
			FROM dbo.PeriodRegView R
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.WeightRules W
					WHERE R.REG_ID_PERIOD = W.ID_PERIOD
						AND R.REG_ID_SYSTEM = W.ID_SYSTEM
						AND R.REG_ID_TYPE = W.ID_TYPE
						AND R.REG_ID_NET = W.ID_NET
				)
				AND REG_ID_PERIOD = @periodid
				AND SYS_ID_HOST = @HOST
				AND DS_REG = 0
		) AS A
		INNER JOIN dbo.SystemTable ON REG_ID_SYSTEM = SYS_ID
		INNER JOIN dbo.SystemTypeTable ON REG_ID_TYPE = SST_ID
		INNER JOIN dbo.SystemNetCountTable ON REG_ID_NET = SNC_ID
		FOR XML PATH('')
	) 
	
	IF @ERR IS NOT NULL
		RAISERROR(@ERR, 16, 2);

	IF EXISTS
		(
			SELECT *
			FROM dbo.PeriodRegTable
			WHERE REG_ID_PERIOD = @periodid
		)
		SELECT 1 AS RES
	ELSE
		SELECT 0 AS RES
END
