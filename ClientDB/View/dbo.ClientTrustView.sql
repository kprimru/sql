USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientTrustView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientTrustView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[ClientTrustView]
WITH SCHEMABINDING
AS
	SELECT
		CT_ID, CC_ID_CLIENT, CT_ID_CALL, CC_DATE, CC_USER,
		CT_MAKE_USER + ' ' + CONVERT(VARCHAR(20), CT_MAKE, 104) + ' ' + CONVERT(VARCHAR(20), CT_MAKE, 108) AS CT_MAKE_DATA,
		CT_NOTE, CT_TRUST, CT_MAKE,
		CASE
			WHEN CT_TRUST = 1 THEN 'Достоверен'
			WHEN CT_TRUST = 0 AND CT_MAKE IS NULL THEN 'Не достоверен'
			WHEN CT_TRUST = 0 AND CT_MAKE IS NOT NULL THEN 'Не достоверен (исправлен)'
			ELSE 'Неизвестно'
		END AS CT_TRUST_STR,
		CASE
			WHEN CT_TRUST = 1 THEN 1
			WHEN CT_TRUST = 0 AND CT_MAKE IS NULL THEN 0
			WHEN CT_TRUST = 0 AND CT_MAKE IS NOT NULL THEN 2
			ELSE -1
		END AS CT_TRUST_STATUS,
		CASE CT_TNAME
			WHEN 1 THEN 'Название: ' + CT_NAME + CHAR(10)
			ELSE ''
		END +
		CASE CT_TADDRESS
			WHEN 1 THEN 'Адрес: ' + CT_ADDRESS + CHAR(10)
			ELSE ''
		END +
		CASE CT_TDIR
			WHEN 1 THEN 'ФИО Руководителя: ' + CT_DIR + CHAR(10)
			ELSE ''
		END +
		CASE CT_TDIR_POS
			WHEN 1 THEN 'Должность Руководителя: ' + CT_DIR_POS + CHAR(10)
			ELSE ''
		END +
		CASE CT_TDIR_PHONE
			WHEN 1 THEN 'Тел. Руководителя: ' + CT_DIR_PHONE + CHAR(10)
			ELSE ''
		END +
		CASE CT_TBUH
			WHEN 1 THEN 'ФИО гл.бух.: ' + CT_BUH + CHAR(10)
			ELSE ''
		END +
		CASE CT_TBUH_POS
			WHEN 1 THEN 'Должность гл.бух.: ' + CT_BUH_POS + CHAR(10)
			ELSE ''
		END +
		CASE CT_TBUH_PHONE
			WHEN 1 THEN 'Тел. гл.бух: ' + CT_BUH_PHONE + CHAR(10)
			ELSE ''
		END +
		CASE CT_TRES
			WHEN 1 THEN 'ФИО ответств.: ' + CT_RES + CHAR(10)
			ELSE ''
		END +
		CASE CT_TRES_POS
			WHEN 1 THEN 'Должность ответств.: ' + CT_RES_POS + CHAR(10)
			ELSE ''
		END +
		CASE CT_TRES_PHONE
			WHEN 1 THEN 'Телефон ответств.: ' + CT_RES_PHONE + CHAR(10)
			ELSE ''
		END AS CT_CORRECT
	FROM
		dbo.ClientTrust
		INNER JOIN dbo.ClientCall ON CC_ID = CT_ID_CALL

GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientTrustView(CT_ID)] ON [dbo].[ClientTrustView] ([CT_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTrustView(CC_DATE,CT_TRUST)] ON [dbo].[ClientTrustView] ([CC_DATE] ASC, [CT_TRUST] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTrustView(CC_ID_CLIENT,CT_TRUST,CT_MAKE)] ON [dbo].[ClientTrustView] ([CC_ID_CLIENT] ASC, [CT_TRUST] ASC, [CT_MAKE] ASC);
GO
