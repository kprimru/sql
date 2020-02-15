USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EXPERT_QUESTION_SUBHOST]
	@SUBHOST	UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ID, SYS, DISTR, COMP, DATE, FIO, EMAIL, PHONE, QUEST, SH_EMAIL,
		CONVERT(NVARCHAR(16), SYS) + '_' + CONVERT(NVARCHAR(16), DISTR) + 
			CASE COMP 
				WHEN 1 THEN '' 
				ELSE '_' + CONVERT(NVARCHAR(8), COMP) 
			END AS COMPLECT,
		(
			SELECT 
				SYS AS '@sys', DISTR AS '@distr', COMP AS '@comp', CONVERT(NVARCHAR(64), DATE, 120) AS '@date', 
				FIO AS 'fio', EMAIL AS 'email', PHONE AS 'phone', QUEST AS 'text'
			FROM dbo.ClientDutyQuestion z
			WHERE z.ID = d.ID
			FOR XML PATH('quest'), ROOT('root')
		) AS QUEST_XML
	FROM
	(
		SELECT
			SH_REG		= '(' + SH_REG + ')%',
			SH_REG_ADD	= '(' + SH_REG_ADD + ')%',
			SH_EMAIL	= SH_EMAIL
		FROM dbo.Subhost
		WHERE SH_REG IN ('Ì', 'Ó1', 'Í1')
	) SH
	CROSS APPLY
	(
		SELECT SystemName, DistrNumber, CompNumber
		FROM
			(
				SELECT a.SystemName, DistrNumber, CompNumber
				FROM dbo.RegNodeTable a
				WHERE Comment LIKE SH_REG OR Comment LIKE SH_REG_ADD

				UNION

				SELECT a.SystemName, DistrNumber, CompNumber
				FROM 
					dbo.RegNodeTable a
					INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
					INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
				WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST

				UNION 

				SELECT SystemName, DistrNumber, CompNumber
				FROM dbo.RegNodeTable
				WHERE Complect IN
					(
						SELECT Complect
						FROM 
							dbo.RegNodeTable a
							INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
							INNER JOIN dbo.SubhostComplect c ON SC_DISTR = DistrNumber AND SC_COMP = CompNumber AND c.SC_ID_HOST = b.HostID
						WHERE SystemReg = 1 AND SC_REG = 1 AND SC_ID_SUBHOST = @SUBHOST
					)
				
				UNION
					
				SELECT a.SystemName, DistrNumber, CompNumber
				FROM dbo.RegNodeTable a
				WHERE Comment LIKE '%' + SH_REG
			) AS o_O
		) AS a
			INNER JOIN dbo.SystemTable b ON b.SystemBaseName = a.SystemName
			INNER JOIN dbo.SystemTable c ON b.HostID = c.HostID
			INNER JOIN dbo.ClientDutyQuestion d ON d.SYS = c.SystemNumber AND d.DISTR = a.DistrNumber AND d.COMP = a.CompNumber
	WHERE d.SUBHOST IS NULL
END
