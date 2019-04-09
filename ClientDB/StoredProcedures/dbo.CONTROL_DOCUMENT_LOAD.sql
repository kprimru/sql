USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONTROL_DOCUMENT_LOAD]
	@LIST	NVARCHAR(MAX),
	@NEW	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @xml XML
	
	SET @xml = CAST(@LIST AS XML)
	
	INSERT INTO dbo.ControlDocument(DATE, RIC, SYS_NUM, DISTR, COMP, IB, IB_NUM, DOC_NAME)
		SELECT DATE, RIC, SYS_NUM, DISTR, COMP, IB, IB_NUM, DOC_NAME
		FROM
			(
				SELECT 
					CONVERT(DATETIME, c.value('(@date)', 'VARCHAR(64)'), 120) AS DATE, 
					c.value('(@ric)', 'SMALLINT') AS RIC, 
					c.value('(@sys)', 'INT') AS SYS_NUM,
					c.value('(@distr)', 'INT') AS DISTR,
					c.value('(@comp)', 'TINYINT') AS COMP,
					c.value('(@ib)', 'VARCHAR(50)') AS IB,
					c.value('(@ib_num)', 'INT') AS IB_NUM,
					c.value('(.)', 'VARCHAR(1024)') AS DOC_NAME
				FROM @xml.nodes('/root/item') AS a(c)
			) AS a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ControlDocument b
				WHERE a.DATE = b.DATE
					AND a.RIC = b.RIC
					AND a.SYS_NUM = b.SYS_NUM
					AND a.DISTR = b.DISTR
					AND a.COMP = b.COMP
					AND a.IB = b.IB
					AND ISNULL(a.IB_NUM, -1) = ISNULL(b.IB_NUM, -1)
					AND a.DOC_NAME = b.DOC_NAME
			)
			
	SELECT @NEW = @@ROWCOUNT
END
