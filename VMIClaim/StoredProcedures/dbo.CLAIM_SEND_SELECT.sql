USE [VMIClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLAIM_SEND_SELECT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TIME	SMALLINT
	DECLARE @TIME2	SMALLINT

	SELECT TOP 1 @TIME = MAIL_TIME, @TIME2 = MAIL_TIME2
	FROM dbo.Config
	ORDER BY UPD_DATE DESC

	SELECT ID, FIO,
		EMAIL,
		--'web-vdu8x@mail-tester.com' AS EMAIL,
		--'bazis@kprim.ru' AS EMAIL,
		DATE, 1 AS TP
	FROM dbo.Claim a
	WHERE TP = 3
		AND
			(
				ID = @ID
				OR
				@ID IS NULL
				AND DATEADD(MINUTE, @TIME, DATE) <= GETDATE()
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.ClaimEmail z
						WHERE z.ID_CLAIM = a.ID
					)
			)
		AND EMAIL NOT LIKE '%gmail.ru'
		AND EMAIL NOT IN ('tyulpan-@200mail.ru', 'tera.nata@yandex.ru9089965910', 'eremenkovevgeny@gmail.cjv', '', 'marina.kuzmina/62@mail.ru',
							'vash.dom25region@gvail.com', 'seryi.am@dvfu.zu', 'chief_apr@zanprim.primorsky.ru', 'irinati2613@gmail.ru',
							'Seloustieva1984@gmail.ru', 'alien125rus@gmail.ru', 'V.Peleganchuk@dvf.rosmorport.r7', 'vasiliska.vdk@gmail.ru',
							'laife1950@mail.9089858408ru', 'kadr@vi-fgup-ohrana.ru', '25resurs@bk.tu', 'poltininadomansraya@mail.ru9241276128',
							'marianna.buh2568@ro.ro', 'kucha67@yandex.ri')

	/*UNION ALL

	SELECT NEWID(), 'Фамилия Имя Отчество', 'denisofff@mail.ru', GETADTE()
	*/

	UNION ALL

	SELECT ID, FIO,
		EMAIL,
		--'web-vdu8x@mail-tester.com' AS EMAIL,
		--'denisofff.alex@gmail.com' AS EMAIL,
		--'denisofff-koalka@yandex.ru' AS EMAIL,
		--'hostsql@kprim.ru' AS EMAIL,
		--'nakhodka@bk.ru' AS EMAIL,
		--'nakhodka@kprim.ru' AS EMAIL,
		--'denisofff@mail.ru' AS EMAIL,
		--'bazis@kprim.ru' AS EMAIL,
		DATE, 2 AS TP
	FROM dbo.Claim a
	WHERE TP = 3
		--AND	@ID IS NULL
		AND DATEADD(MINUTE, @TIME2, DATE) <= GETDATE()
		AND NOT EXISTS
			(
				SELECT *
				FROM dbo.ClaimEmail2 z
				WHERE z.ID_CLAIM = a.ID
			)
		AND EXISTS
			(
				SELECT *
				FROM dbo.ClaimEmail z
				WHERE z.ID_CLAIM = a.ID
			)
		AND EMAIL NOT IN ('tyulpan-@200mail.ru')

	ORDER BY DATE
END
GRANT EXECUTE ON [dbo].[CLAIM_SEND_SELECT] TO rl_robot;
GO