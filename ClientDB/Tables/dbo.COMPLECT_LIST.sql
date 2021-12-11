USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[COMPLECT_LIST]
(
        [ID]           Int             Identity(1,1)   NOT NULL,
        [ID_VARIANT]   Int                             NOT NULL,
        [NAME]         VarChar(250)                    NOT NULL,
        [PATH]         VarChar(1024)                   NOT NULL,
        [P_DATE]       Bit                             NOT NULL,
        [P_DVD5]       Bit                             NOT NULL,
        [P_CLEAR]      Bit                             NOT NULL,
        [P_ACTIVE]     Bit                             NOT NULL,
        [PATH_BASE]    VarChar(1024)                       NULL,
        [PATH_ISO]     VarChar(1024)                       NULL,
        [P_RGT]        Bit                                 NULL,
        CONSTRAINT [PK_dbo.COMPLECT_LIST] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.COMPLECT_LIST(ID_VARIANT)_dbo.COMPLECT_VARIANT(ID)] FOREIGN KEY  ([ID_VARIANT]) REFERENCES [dbo].[COMPLECT_VARIANT] ([ID])
);
GO
GRANT ALTER ON [dbo].[COMPLECT_LIST] TO COMPLECTBASE;
GRANT CONTROL ON [dbo].[COMPLECT_LIST] TO COMPLECTBASE;
GRANT DELETE ON [dbo].[COMPLECT_LIST] TO COMPLECTBASE;
GRANT INSERT ON [dbo].[COMPLECT_LIST] TO COMPLECTBASE;
GRANT REFERENCES ON [dbo].[COMPLECT_LIST] TO COMPLECTBASE;
GRANT SELECT ON [dbo].[COMPLECT_LIST] TO COMPLECTBASE;
GRANT UPDATE ON [dbo].[COMPLECT_LIST] TO COMPLECTBASE;
GO
