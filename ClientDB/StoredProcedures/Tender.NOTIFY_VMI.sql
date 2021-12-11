USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[NOTIFY_VMI]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[NOTIFY_VMI]  AS SELECT 1')
GO
ALTER PROCEDURE [Tender].[NOTIFY_VMI]
	@OFFER	UNIQUEIDENTIFIER,
	@TENDER	UNIQUEIDENTIFIER = NULL,
	@CLIENT	NVARCHAR(256) = NULL,
	@ADDRESS	NVARCHAR(2048) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		-- {\LETTER_DATE}
		-- {\CLIENT}
		-- {\TENDER_TYPE}
		-- {\OPERATIONS}
		-- {\URL}
		-- {\CLIENT_ADDRESS}

		IF @OFFER IS NOT NULL
			SELECT
				CLIENT, TENDER_TYPE, URL, CLIENT_ADDRESS, SUBJECT,

				'������������!' + CHAR(10) +
				'����� ��������� ����������� c ������������ ������ ��� 020 �� ����������� ����� tender@consultant.ru' + CHAR(10) +
				'� ����� ������ ���������� �������: ���� �020-���������� ��� �� � ������� �������'
						AS MAIL_BODY,

				'��� 020' AS HEADER1,
				'��� ��-����' AS HEADER2,
				'�. �����������' AS HEADER3,
				'���. � {\LET_NUM} �� {\LET_DATE}�.' AS HEADER4,
				'�� ���������������' AS HEADER5,
				'�����: ��� �490' AS HEADER6,

				LET_DATE,
				LET_NUM
			FROM
				(
					SELECT
						b.CLIENT,
						d.PK_NAME AS [TENDER_TYPE], c.URL,
						CASE
							WHEN
								(
									SELECT COUNT(*)
									FROM
										(
											SELECT DISTINCT CLIENT, ADDRESS
											FROM Tender.OfferDetail z
											WHERE z.ID_OFFER = a.ID
										) AS o_O
								) = 1 THEN '��������, ��� ������ ������, ������������� �� ������: '
							ELSE '��������, ��� ������ ������ (� ������������� �������, ���������� � ��������� ������������), ' +
								'������������� �� ������������� �������, �������� �������������� ������������� ������ ���:' + CHAR(10)
						END +
						CASE
							WHEN
								(
									SELECT COUNT(*)
									FROM
										(
											SELECT DISTINCT CLIENT, ADDRESS
											FROM Tender.OfferDetail z
											WHERE z.ID_OFFER = a.ID
										) AS o_O
								) = 1 THEN
									(
										SELECT TOP 1 ADDRESS
										FROM Tender.OfferDetail z
										WHERE z.ID_OFFER = a.ID
									) + ', �������� �������������� ������������� ������ ���.'
							ELSE
								REVERSE(STUFF(REVERSE(
									(
										SELECT ADDRESS + ', ' + CLIENT + CHAR(10)
										FROM
											(
												SELECT DISTINCT CLIENT, ADDRESS
												FROM Tender.OfferDetail z
												WHERE z.ID_OFFER = a.ID
											) AS o_O
										ORDER BY CLIENT, ADDRESS FOR XML PATH('')
									)
								), 1, 1, ''))
						END AS CLIENT_ADDRESS,
						SUBJECT, CLAIM_FINISH, LET_NUM, LET_DATE
					FROM
						Tender.Offer a
						INNER JOIN Tender.Tender b ON a.ID_TENDER = b.ID
						INNER JOIN Tender.Placement c ON b.ID = c.ID_TENDER
						INNER JOIN Purchase.PurchaseKind d ON c.ID_TYPE = d.PK_ID
					WHERE a.ID = @OFFER
				) AS o_O
		ELSE
			SELECT
				CLIENT, TENDER_TYPE, URL, CLIENT_ADDRESS, SUBJECT,

				'������������!' + CHAR(10) +
				'����� ��������� ����������� c ������������ ������ ��� 020 �� ����������� ����� tender@consultant.ru' + CHAR(10) +
				'� ����� ������ ���������� �������: ���� �020-���������� ��� �� � ������� �������'
						AS MAIL_BODY,

				'��� 020' AS HEADER1,
				'��� ��-����' AS HEADER2,
				'�. �����������' AS HEADER3,
				'���. � {\LET_NUM} �� {\LET_DATE}�.' AS HEADER4,
				'�� ���������������' AS HEADER5,
				'�����: ��� �490' AS HEADER6,

				LET_DATE,
				LET_NUM
			FROM
				(
					SELECT
						CONVERT(NVARCHAR(32), GETDATE(), 104) AS LETTER_DATE,
						b.CLIENT,
						d.PK_NAME AS [TENDER_TYPE], c.URL,
						'��������, ��� ������ ������, ������������� �� ������: ' + @ADDRESS + ', �������� �������������� ������������� ������ ���.' AS CLIENT_ADDRESS,
						SUBJECT,
						CLAIM_FINISH,
						LET_DATE, LET_NUM
					FROM
						Tender.Tender b
						INNER JOIN Tender.Placement c ON b.ID = c.ID_TENDER
						INNER JOIN Purchase.PurchaseKind d ON c.ID_TYPE = d.PK_ID
					WHERE b.ID = @TENDER
				) AS o_O

			EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[NOTIFY_VMI] TO rl_tender_r;
GO
