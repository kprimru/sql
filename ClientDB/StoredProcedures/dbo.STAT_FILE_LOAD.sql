USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STAT_FILE_LOAD]
	@DATA	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @XML XML
	
	SET @XML = CAST(@DATA AS XML)
		
	INSERT INTO dbo.StatisticTable(StatisticDate, InfoBankID, Docs)
		SELECT DT, InfoBankID, DOC
		FROM
			(
				SELECT DATEADD(DAY, 1, DT) AS DT, InfoBankID, DOC
				FROM
				(
					SELECT 
						CONVERT(SMALLDATETIME, c.value('(@date)', 'VARCHAR(20)'), 104) AS DT,
						c.value('(@ib)', 'VARCHAR(50)') AS IB,					
						c.value('(@docs)', 'INT') AS DOC
					FROM 
						@xml.nodes('/root/item') AS a(c)
				) AS a
				INNER JOIN dbo.InfoBankTable ON InfoBankName = IB
				WHERE (IB LIKE 'RLAW%' OR IB IN ('SPB')) AND IB != 'RLAW020'
			) AS a
		WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.StatisticTable z
			WHERE z.InfoBankID = a.InfoBankID
				AND z.StatisticDate = a.DT
		)
END
