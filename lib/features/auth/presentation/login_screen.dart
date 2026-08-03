
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/dashboardrouter.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/appsnackbar.dart';
import '../../forgotpassword/forgotpswd.dart';
import '../bloc/auth_bloc.dart';
import '../data/auth_repository.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authRepository: AuthRepository()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView>
    with SingleTickerProviderStateMixin {
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: (context, state) {
          if (state.status == AuthStatus.success && state.role != null) {
            AppSnackbar.success('Welcome back, ${state.name ?? ''}'.trim());

            // Single source of truth for role -> dashboard mapping,
            // shared with SplashScreen's auto-login path.
            final destination = destinationForRole(state.role!);

            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 350),
                pageBuilder: (_, anim, __) => destination,
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            );
          } else if (state.status == AuthStatus.failure &&
              state.errorMessage != null) {
            AppSnackbar.error(state.errorMessage!);
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ClipPath(
                clipper: _HeaderClipper(),
                child: Container(
                  height: Responsive.h(240),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: _Brand(),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(22)),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: Responsive.h(28)),
                    FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: _FormCard(
                            phoneFocus: _phoneFocus,
                            passwordFocus: _passwordFocus,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(20)),
                    Text(
                      'Ceramo · Inventory & Sales Console',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption(
                        color: AppColors.textHint,
                      ),
                    ),
                    SizedBox(height: Responsive.h(24)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Logo chip + wordmark, sitting on top of the header band.
class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: Responsive.w(64),
          height: Responsive.w(64),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(Responsive.w(18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.all(Responsive.w(12)),
          child: Image.asset(
            'assets/images/logo/logo.png',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: Responsive.h(14)),
        Text(
          'CERAMO',
          style: AppTextStyles.h1(color: AppColors.white).copyWith(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        SizedBox(height: Responsive.h(4)),
        Text(
          'Enterprise Operations Portal',
          style: AppTextStyles.caption(
            color: AppColors.white.withOpacity(0.85),
          ),
        ),
      ],
    );
  }
}

/// The elevated white sign-in card.
class _FormCard extends StatelessWidget {
  final FocusNode phoneFocus;
  final FocusNode passwordFocus;

  const _FormCard({required this.phoneFocus, required this.passwordFocus});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        Responsive.w(24),
        Responsive.h(28),
        Responsive.w(24),
        Responsive.h(24),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Responsive.w(22)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sign in', style: AppTextStyles.h1()),
          SizedBox(height: Responsive.h(4)),
          Text(
            'Use your work account to continue',
            style: AppTextStyles.subtitle(),
          ),
          SizedBox(height: Responsive.h(26)),

          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (p, c) => p.status != c.status,
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel('EMAIL ADDRESS'),
                  SizedBox(height: Responsive.h(8)),
                  _BrandField(
                    focusNode: phoneFocus,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) =>
                        context.read<AuthBloc>().add(AuthEmailChanged(v)),
                  ),
                  SizedBox(height: Responsive.h(18)),

                  const _FieldLabel('PASSWORD'),
                  SizedBox(height: Responsive.h(8)),
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (p, c) =>
                    p.obscurePassword != c.obscurePassword,
                    builder: (context, s) {
                      return _BrandField(
                        focusNode: passwordFocus,
                        icon: Icons.lock_outline_rounded,
                        obscureText: s.obscurePassword,
                        onChanged: (v) => context
                            .read<AuthBloc>()
                            .add(AuthPasswordChanged(v)),
                        suffix: IconButton(
                          splashRadius: 18,
                          icon: Icon(
                            s.obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textHint,
                            size: 20,
                          ),
                          onPressed: () => context
                              .read<AuthBloc>()
                              .add(const AuthTogglePasswordVisibility()),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: Responsive.h(10)),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, Responsive.h(28)),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot password?',
                        style: AppTextStyles.bodyBold(color: AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(20)),

                  _BrandButton(
                    label: state.status == AuthStatus.submitting
                        ? 'Signing in…'
                        : 'Sign in',
                    isLoading: state.status == AuthStatus.submitting,
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(const AuthLoginSubmitted()),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Small uppercase field label.
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.caption(color: AppColors.textHint).copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        fontSize: 11,
      ),
    );
  }
}

class _BrandField extends StatefulWidget {
  final FocusNode focusNode;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;
  final Widget? suffix;

  const _BrandField({
    required this.focusNode,
    required this.icon,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  State<_BrandField> createState() => _BrandFieldState();
}

class _BrandFieldState extends State<_BrandField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() => _focused = widget.focusNode.hasFocus);

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focused ? AppColors.primary : AppColors.border,
          width: _focused ? 1.6 : 1.2,
        ),
      ),
      child: TextField(
        focusNode: widget.focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged,
        style: AppTextStyles.body(color: AppColors.textPrimary),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          isDense: true,
          hintStyle: AppTextStyles.body(color: AppColors.textHint),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 4, right: 2),
            child: Icon(
              widget.icon,
              color: _focused ? AppColors.primary : AppColors.textHint,
              size: 19,
            ),
          ),
          prefixIconConstraints:
          const BoxConstraints(minWidth: 40, minHeight: 20),
          suffixIcon: widget.suffix,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        ),
      ),
    );
  }
}

/// Primary CTA — brand-red gradient fill with a soft red glow shadow and a
/// loading spinner.
class _BrandButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _BrandButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: isLoading ? null : onPressed,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                label,
                style: AppTextStyles.bodyBold(color: AppColors.white)
                    .copyWith(fontSize: 15.5, letterSpacing: 0.2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}