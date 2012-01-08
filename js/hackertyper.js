function getNextBlock()
{
var code = "struct group_info init_groups = { .usage = ATOMIC_INIT(2) };\n\
struct group_info *groups_alloc(int gidsetsize){\n\
    struct group_info *group_info;\n\
    int nblocks;\n\
    int i;\n\
\n\
    nblocks = (gidsetsize + NGROUPS_PER_BLOCK - 1) / NGROUPS_PER_BLOCK;\n\
\n\
    /* Make sure we always allocate at least one indirect block pointer */\n\
    nblocks = nblocks ? : 1;\n\
    group_info = kmalloc(sizeof(*group_info) + nblocks*sizeof(gid_t *), GFP_USER);\n\
\n\
    if (!group_info)\n\
        return NULL;\n\
\n\
    group_info->ngroups = gidsetsize;\n\
    group_info->nblocks = nblocks;\n\
    atomic_set(&group_info->usage, 1);\n\
\n\
    if (gidsetsize <= NGROUPS_SMALL)\n\
        group_info->blocks[0] = group_info->small_block;\n\
    else {\n\
        for (i = 0; i < nblocks; i++) {\n\
            gid_t *b;\n\
            b = (void *)__get_free_page(GFP_USER);\n\
            if (!b)\n\
                goto out_undo_partial_alloc;\n\
\n\
            group_info->blocks[i] = b;\n\
        }\n\
        }\n\
        return group_info;\n\
\n\
out_undo_partial_alloc:\n\
        while (--i >= 0) {\n\
                free_page((unsigned long)group_info->blocks[i]);\n\
        }\n\
        kfree(group_info);\n\
        return NULL;\n\
}\n\
\n\
EXPORT_SYMBOL(groups_alloc);\n\
\n\
void groups_free(struct group_info *group_info)\n\
{\n\
        if (group_info->blocks[0] != group_info->small_block) {\n\
                int i;\n\
                for (i = 0; i < group_info->nblocks; i++)\n\
                        free_page((unsigned long)group_info->blocks[i]);\n\
        }\n\
        kfree(group_info);\n\
}\n\
\n\
EXPORT_SYMBOL(groups_free);\n\
\n\
/* export the group_info to a user-space array */\n\
static int groups_to_user(gid_t __user *grouplist,\n\
                          const struct group_info *group_info)\n\
{\n\
        int i;\n\
        unsigned int count = group_info->ngroups;\n\
\n\
        for (i = 0; i < group_info->nblocks; i++) {\n\
                unsigned int cp_count = min(NGROUPS_PER_BLOCK, count);\n\
                unsigned int len = cp_count * sizeof(*grouplist);\n\
\n\
                if (copy_to_user(grouplist, group_info->blocks[i], len))\n\
                        return -EFAULT;\n\
\n\
                grouplist += NGROUPS_PER_BLOCK;\n\
                count -= cp_count;\n\
        }\n\
        return 0;\n\
}\n\
\n\
/* fill a group_info from a user-space array - it must be allocated already */\n\
static int groups_from_user(struct group_info *group_info,\n\
    gid_t __user *grouplist)\n\
{\n\
        int i;\n\
        unsigned int count = group_info->ngroups;\n\
\n\
        for (i = 0; i < group_info->nblocks; i++) {\n\
                unsigned int cp_count = min(NGROUPS_PER_BLOCK, count);\n\
                unsigned int len = cp_count * sizeof(*grouplist);\n\
\n\
                if (copy_from_user(group_info->blocks[i], grouplist, len))\n\
\n\
                        return -EFAULT;\n\
\n\
\n\
\n\
                grouplist += NGROUPS_PER_BLOCK;\n\
\n\
                count -= cp_count;\n\
\n\
        }\n\
\n\
        return 0;\n\
\n\
}\n\
\n\
\n\
\n\
/* a simple Shell sort */\n\
\n\
static void groups_sort(struct group_info *group_info)\n\
\n\
{\n\
\n\
        int base, max, stride;\n\
\n\
        int gidsetsize = group_info->ngroups;\n\
\n\
\n\
\n\
        for (stride = 1; stride < gidsetsize; stride = 3 * stride + 1)\n\
\n\
                ; /* nothing */\n\
\n\
        stride /= 3;\n\
\n\
\n\
\n\
        while (stride) {\n\
\n\
                max = gidsetsize - stride;\n\
\n\
                for (base = 0; base < max; base++) {\n\
\n\
                        int left = base;\n\
\n\
                        int right = left + stride;\n\
\n\
                        gid_t tmp = GROUP_AT(group_info, right);\n\
\n\
\n\
\n\
                        while (left >= 0 && GROUP_AT(group_info, left) > tmp) {\n\
\n\
                                GROUP_AT(group_info, right) =\n\
\n\
                                    GROUP_AT(group_info, left);\n\
\n\
                                right = left;\n\
\n\
                                left -= stride;\n\
\n\
                        }\n\
\n\
                        GROUP_AT(group_info, right) = tmp;\n\
\n\
                }\n\
\n\
                stride /= 3;\n\
\n\
        }\n\
\n\
}\n\
\n\
\n\
\n\
/* a simple bsearch */\n\
\n\
int groups_search(const struct group_info *group_info, gid_t grp)\n\
\n\
{\n\
\n\
        unsigned int left, right;\n\
\n\
\n\
\n\
        if (!group_info)\n\
\n\
                return 0;\n\
\n\
\n\
\n\
        left = 0;\n\
\n\
        right = group_info->ngroups;\n\
\n\
        while (left < right) {\n\
\n\
                unsigned int mid = (left+right)/2;\n\
\n\
                if (grp > GROUP_AT(group_info, mid))\n\
\n\
                        left = mid + 1;\n\
\n\
                else if (grp < GROUP_AT(group_info, mid))\n\
\n\
                        right = mid;\n\
\n\
                else\n\
\n\
                        return 1;\n\
\n\
        }\n\
\n\
        return 0;\n\
\n\
}\n\
\n\
\n\
\n\
/**\n\
\n\
 * set_groups - Change a group subscription in a set of credentials\n\
\n\
 * @new: The newly prepared set of credentials to alter\n\
\n\
 * @group_info: The group list to install\n\
\n\
 *\n\
\n\
 * Validate a group subscription and, if valid, insert it into a set\n\
\n\
 * of credentials.\n\
\n\
 */\n\
\n\
int set_groups(struct cred *new, struct group_info *group_info)\n\
\n\
{\n\
\n\
        put_group_info(new->group_info);\n\
\n\
        groups_sort(group_info);\n\
\n\
        get_group_info(group_info);\n\
\n\
        new->group_info = group_info;\n\
\n\
        return 0;\n\
\n\
}\n\
\n\
\n\
\n\
EXPORT_SYMBOL(set_groups);\n\
\n\
\n\
\n\
/**\n\
\n\
 * set_current_groups - Change current's group subscription\n\
\n\
 * @group_info: The group list to impose\n\
\n\
 *\n\
\n\
 * Validate a group subscription and, if valid, impose it upon current's task\n\
\n\
 * security record.\n\
\n\
 */\n\
\n\
int set_current_groups(struct group_info *group_info)\n\
\n\
{\n\
\n\
        struct cred *new;\n\
\n\
        int ret;\n\
\n\
\n\
\n\
        new = prepare_creds();\n\
\n\
        if (!new)\n\
\n\
                return -ENOMEM;\n\
\n\
\n\
\n\
        ret = set_groups(new, group_info);\n\
\n\
        if (ret < 0) {\n\
\n\
                abort_creds(new);\n\
\n\
                return ret;\n\
\n\
        }\n\
\n\
\n\
\n\
        return commit_creds(new);\n\
\n\
}\n\
\n\
\n\
\n\
EXPORT_SYMBOL(set_current_groups);\n\
\n\
\n\
\n\
SYSCALL_DEFINE2(getgroups, int, gidsetsize, gid_t __user *, grouplist)\n\
\n\
{\n\
\n\
        const struct cred *cred = current_cred();\n\
\n\
        int i;\n\
\n\
\n\
\n\
        if (gidsetsize < 0)\n\
\n\
                return -EINVAL;\n\
\n\
\n\
\n\
        /* no need to grab task_lock here; it cannot change */\n\
\n\
        i = cred->group_info->ngroups;\n\
\n\
        if (gidsetsize) {\n\
\n\
                if (i > gidsetsize) {\n\
\n\
                        i = -EINVAL;\n\
\n\
                        goto out;\n\
\n\
                }\n\
\n\
                if (groups_to_user(grouplist, cred->group_info)) {\n\
\n\
                        i = -EFAULT;\n\
\n\
                        goto out;\n\
\n\
                }\n\
\n\
        }\n\
\n\
out:\n\
\n\
        return i;\n\
\n\
}\n\
\n\
\n\
\n\
/*\n\
\n\
 *	SMP: Our groups are copy-on-write. We can set them safely\n\
\n\
 *	without another task interfering.\n\
\n\
 */\n\
\n\
\n\
\n\
SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __user *, grouplist)\n\
\n\
{\n\
\n\
        struct group_info *group_info;\n\
\n\
        int retval;\n\
\n\
\n\
\n\
        if (!nsown_capable(CAP_SETGID))\n\
\n\
                return -EPERM;\n\
\n\
        if ((unsigned)gidsetsize > NGROUPS_MAX)\n\
\n\
                return -EINVAL;\n\
\n\
\n\
\n\
        group_info = groups_alloc(gidsetsize);\n\
\n\
        if (!group_info)\n\
\n\
                return -ENOMEM;\n\
\n\
        retval = groups_from_user(group_info, grouplist);\n\
\n\
        if (retval) {\n\
\n\
                put_group_info(group_info);\n\
\n\
                return retval;\n\
\n\
        }\n\
\n\
\n\
\n\
        retval = set_current_groups(group_info);\n\
\n\
        put_group_info(group_info);\n\
\n\
\n\
\n\
        return retval;\n\
\n\
}\n\
\n\
\n\
\n\
/*\n\
\n\
 * Check whether we're fsgid/egid or in the supplemental group..\n\
\n\
 */\n\
\n\
int in_group_p(gid_t grp)\n\
\n\
{\n\
\n\
        const struct cred *cred = current_cred();\n\
\n\
        int retval = 1;\n\
\n\
\n\
\n\
        if (grp != cred->fsgid)\n\
\n\
                retval = groups_search(cred->group_info, grp);\n\
\n\
        return retval;\n\
\n\
}\n\
\n\
\n\
\n\
EXPORT_SYMBOL(in_group_p);\n\
\n\
\n\
\n\
int in_egroup_p(gid_t grp)\n\
\n\
{\n\
\n\
        const struct cred *cred = current_cred();\n\
\n\
        int retval = 1;\n\
\n\
\n\
\n\
        if (grp != cred->egid)\n\
\n\
                retval = groups_search(cred->group_info, grp);\n\
\n\
        return retval;\n\
\n\
}";
    var out = code.substr(0, textEdit.codePos+textEdit.speed);
    textEdit.codePos += textEdit.speed;
    textEdit.text = out;
    updateFlickArea();
}
