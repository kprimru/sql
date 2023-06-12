USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EIS@Create?Document(Internal)]', 'IF') IS NULL EXEC('CREATE FUNCTION [dbo].[EIS@Create?Document(Internal)] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [dbo].[EIS@Create?Document(Internal)]
(
    @Act_Id			Int,
	@Invoice_Id		Int,
	@File_Id        VarChar(100),
	@MainContent    VarChar(Max),
    @ApplyContent   VarChar(Max)
)
RETURNS TABLE
AS
RETURN
(
	SELECT [Data] =
		(
			SELECT
				[ИдТрПакет]     = Cast((SELECT [NewId] FROM [dbo].[NewIdView]) AS VarChar(100)),
				[ИдФайл]        = 'ON_NSCHFDOPPR_' + F.[EIS_CODE] + '_' + O.[EIS_CODE] + '_' + Convert(VarChar(20), GetDate(), 112) + '_' + @File_Id,
				[ВерсФорм]      = '1.01',
				[ТипПрилож]     = 'УПДПрод',
				[ИдОтпр]        = O.[EIS_CODE],
				[ИдПол]         = F.[EIS_CODE],
				[ДатаВрФормир]  = GetDate(),
				(
					SELECT
						[Контент] = B.[MainBase64]
					FOR XML PATH('Документ'), TYPE
				),
				(
					SELECT
						[Контент] = B.[ApplyBase64]
					FOR XML PATH('Прилож'), TYPE
				)
			FROM
			(
				SELECT ACT_ID_ORG, ACT_ID_PAYER, ACT_ID_CLIENT
				FROM dbo.ActTable AS A
				WHERE ACT_ID = @Act_Id

				UNION ALL

				SELECT INS_ID_ORG, INS_ID_PAYER, INS_ID_CLIENT
				FROM dbo.InvoiceSaleTable
				WHERE INS_ID = @Invoice_Id
			) AS A
			INNER JOIN dbo.OrganizationTable AS O ON A.ACT_ID_ORG = O.ORG_ID
			INNER JOIN dbo.ClientFinancing AS F ON F.ID_CLIENT = IsNull(ACT_ID_PAYER, ACT_ID_CLIENT)

			FOR XML RAW('ФайлПакет'), TYPE
		)
	FROM
	(
		SELECT
			[MainBase64]	= (SELECT CAST('<?xml version="1.0" encoding="windows-1251" standalone="yes"?>' + Convert(VarChar(Max), @MainContent, 1) AS VarBinary(Max)) FOR XML PATH(''), BINARY BASE64),
			[ApplyBase64]	= (SELECT CAST('<?xml version="1.0" encoding="windows-1251" standalone="yes"?>' + Convert(VarChar(Max), @ApplyContent, 1) AS VarBinary(Max)) FOR XML PATH(''), BINARY BASE64)
	) AS B
)GO
