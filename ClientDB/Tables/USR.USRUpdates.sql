USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [USR].[USRUpdates]
(
        [UIU_ID_IB]     Int                NOT NULL,
        [UIU_INDX]      TinyInt            NOT NULL,
        [UIU_DATE]      SmallDateTime      NOT NULL,
        [UIU_SYS]       SmallDateTime      NOT NULL,
        [UIU_DOCS]      Int                NOT NULL,
        [UIU_ID_KIND]   TinyInt            NOT NULL,
        [UIU_DATE_S]     AS (CONVERT([smalldatetime],CONVERT([varchar](8),[UIU_DATE],(112)),(112))) ,
        CONSTRAINT [PK_USR.USRUpdates] PRIMARY KEY CLUSTERED ([UIU_ID_IB],[UIU_INDX]),
        CONSTRAINT [FK_USR.USRUpdates(UIU_ID_IB)_USR.USRIB(UI_ID)] FOREIGN KEY  ([UIU_ID_IB]) REFERENCES [USR].[USRIB] ([UI_ID]),
        CONSTRAINT [FK_USR.USRUpdates(UIU_ID_KIND)_USR.USRFileKindTable(USRFileKindID)] FOREIGN KEY  ([UIU_ID_KIND]) REFERENCES [dbo].[USRFileKindTable] ([USRFileKindID])
);
GO
